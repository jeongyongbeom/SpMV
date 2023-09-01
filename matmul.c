///////////////////////////////////////
// Compare  matrix multiplicaiton output between SW and HW
// HOW TO COMPILE :
// gcc ~/matmul_test.c -o matmul_test
///////////////////////////////////////
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <stdint.h>

// H2F BUS BASE OFFSET
#define FPGA_AXI_BASE   0xC0000000
#define FPGA_AXI_SPAN   0x00001000

// ONCHIP BASE OFFSET
#define ONCHIP_OFFSET   0x08000000
#define ONCHIP_SPAN     0x00000fff
#define HPS_ONCHIP_BASE         0xffff0000
#define HPS_ONCHIP_SPAN         0x00010000

volatile unsigned int * onchip_ptr = NULL ;
volatile unsigned int * value_ptr = NULL ;
volatile unsigned int * format_ptr = NULL ;
volatile unsigned int * result_ptr = NULL ;

int fd;

int main(void)
{
        int i;
        int j;
        int k;

        // # non-zero data, 차후에 동적할당할 것.
        int num_nnz = 6;

        // COO Format Data
        __fp16 coo_value[6] = {1.03, 5.2, 7, 3.1, 10, 2};
        uint8_t coo_row[6] = {1, 2, 6, 10, 11, 14};
        uint8_t coo_col[6] = {0, 3, 7, 11, 13, 14};

        __fp16 in_vector[16] = {1, 3.1, 31, 0.41, 0.18, 6.31, 3, 8, 0, 1.2, 57.1, 31.3, 4.1, 1.2, 75, 31};

        // CSR Format Data
        uint8_t row_counts[16];
        uint8_t csr_row[17];
        uint8_t csr_col[3];

        // Encoded Data
        // value_sw = Input Vector(32-byte) + Value(512-byte)
        // format_sw = Column Index(128-byte) + Row Pointer(17-byte)
        __fp16 value_sw[272];
        uint8_t format_sw[145];
        __fp16 result_sw[16];

        int test=0;
        double a, b, c, d;
        struct timespec begin0, end0;
        struct timespec begin1, end1;
        struct timespec begin2, end2;
        struct timespec begin3, end3;

        // === get FPGA addresses ==================
        if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 )    {
                printf( "ERROR: could not open \"/dev/mem\"...\n" );
                return( 1 );
        }

        // ===========================================
        // get virtual address for onchip sram
        // AXI bus addr + Onchip offset
        onchip_ptr = mmap( NULL, ONCHIP_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_AXI_BASE + ONCHIP_OFFSET);

        if( onchip_ptr == MAP_FAILED ) {
                printf( "ERROR: onchip_ptr mmap() failed...\n" );
                close( fd );
                return(1);
        }

        value_ptr = onchip_ptr + 120;
        format_ptr = onchip_ptr + 256;
        result_ptr = onchip_ptr + 384;

        printf("\nclear result before start\n");
        for(i=0; i<8; i++)
        {
                *(result_ptr + i) = 0;
        }

        printf("result:\n");
        for(i=0; i<8; i++)
        {
                printf("%d  ", *(result_ptr + i));
        }
        printf("\n");

        //// SW matrix multiplication ////////////////////////////////////////////

        printf("\ninput initialization\n");
        clock_gettime(CLOCK_MONOTONIC, &begin0);
        // Assign input vector to value_sw
        for(i=0; i<16; i++)
        {
                value_sw[i] = in_vector[i];
        }
        // Assign matrix value to value_sw
        for(i=0; i<num_nnz; i++)
        {
                value_sw[16+i] = coo_value[i];
        }

        // Encode Row Index to Row Pointer & Assign Row Pointer to format_sw
        for(i=0; i<16; i++)
        {
                row_counts[i] = 0;
        }

        for(i=0; i<num_nnz; i++)
        {
                row_counts[coo_row[i]]++;
        }

        for(i=0; i<17; i++)
        {
                csr_row[i] = 0;
        }

        for(i=0; i<16; i++)
        {
                csr_row[i+1] = csr_row[i] + row_counts[i];
        }

        for(i=0; i<17; i++)
        {
                format_sw[i] = csr_row[i];
        }

        for(i=0; i<num_nnz/2; i++)
        {
                        csr_col[i] = (coo_col[2*i])<<4;
                        csr_col[i] = csr_col[i] + coo_col[2*i+1];
                        format_sw[i+17] = csr_col[i];
        }

        clock_gettime(CLOCK_MONOTONIC, &end0);
        printf("\nin_vector_sw:\n");

        for(i=0; i<16; i++)
        {
                printf("%f  ", *(value_sw + i));
        }

        printf("\nvalue_sw:\n");

        for(i=0; i < num_nnz; i++)
        {
                printf("%f  ", *(value_sw + 16 + i));
         }

        printf("\ncsr_row_sw:\n");
        for(i=0; i<17; i++)
        {
                printf("%d  ", *(format_sw + i));
        }

        printf("\ncsr_col_sw:\n");
        for(i=0; i<num_nnz/2; i++)
        {
                printf("%x  ", *(format_sw + 17 + i));
        }


        clock_gettime(CLOCK_MONOTONIC, &begin1);

        // coo format matrix multiplication
        for(i=0; i<16; i++)
        {
                float sum = 0.0;
                for(j=0; j<num_nnz; j++)
                {
                        if(coo_row[j] == i)
                        {
                                sum += coo_value[j] * in_vector[coo_col[j]];
                        }
                }
                result_sw[i] = sum;
        }

        clock_gettime(CLOCK_MONOTONIC, &end1);

        printf("\nSW end\n");

        //////////////////////////////////////////////////////////////////////////////

        //// HW matrix multiplication ///////////////////////////////////////////////
        printf("\ninput copy to onchip M10K memory\n");
        clock_gettime(CLOCK_MONOTONIC, &begin2);
        memcpy(value_ptr, value_sw, 544);
        memcpy(format_ptr, format_sw, 145);
        clock_gettime(CLOCK_MONOTONIC, &end2);

        printf("\npolling\n");
        clock_gettime(CLOCK_MONOTONIC, &begin3);
        *(onchip_ptr) = 1;
        while(*(onchip_ptr) != 0)
        {
                ;
        }
        clock_gettime(CLOCK_MONOTONIC, &end3);
        printf("\nHW end\n");

        ///////////////////////////////////////////////////////////////////////////////

        printf("value:\n");
        for(i=0; i<272; i++)
        {
                printf("%d  ", *(value_ptr + i));
        }
        printf("\nformat:\n");
        for(i=0; i<145; i++)
        {
                printf("%d  ", *(format_ptr + i));
        }

        printf("\nsw_output:\n");
        for(i=0; i<16; i++)
        {
                printf("%f  ", *(result_sw + i));
        }

        printf("\nresult:\n");
        for(i=0; i<8; i++)
        {
                printf("%d  ", *(result_ptr + i));
        }


        // COMPARE OUTPUT
        for(i=0; i<8; i++)
        {

                for(j=0; j<8; j++)
                {
                        if(*(result_ptr + i*8 + j) != result_sw[i*8+j])
                        {
                                test = 1;
                        }
                }
        }
        printf("\n");

        a = ((double)(end0.tv_sec - begin0.tv_sec)*1000000) + ((double)((end0.tv_nsec - begin0.tv_nsec) / 1000));
        b = ((double)(end1.tv_sec - begin1.tv_sec)*1000000) + ((double)((end1.tv_nsec - begin1.tv_nsec) / 1000));
        c = ((double)(end2.tv_sec - begin2.tv_sec)*1000000) + ((double)((end2.tv_nsec - begin2.tv_nsec) / 1000));
        d = ((double)(end3.tv_sec - begin3.tv_sec)*1000000) + ((double)((end3.tv_nsec - begin3.tv_nsec) / 1000));

        if(test == 0)
        {
                printf("TEST PASSED!");
        }
        else if(test == 1)
        {
                printf("TEST FAILED!");
        }
        printf("\n SW matmul performance : %lf us, HW matmul performance : %lf us", b, d);
        printf("\n SW data transfer : %lf us, SW to HW data transfer %lf us", a, c);

        printf("\n");

}
