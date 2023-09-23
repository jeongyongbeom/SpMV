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
volatile unsigned int * in_vector_ptr = NULL ;
volatile unsigned int * mat_vector_ptr = NULL ;
volatile unsigned int * row_ptr_ptr = NULL;
volatile unsigned int * col_idx_ptr = NULL;
volatile unsigned int * result_ptr = NULL ;

int fd;

int main(void)
{

        int i;
        int j;
        int k;

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

        in_vector_ptr   = onchip_ptr + 120;
        mat_vector_ptr  = onchip_ptr + 128;
        row_ptr_ptr             = onchip_ptr + 256;
        col_idx_ptr             = onchip_ptr + 264;
        result_ptr              = onchip_ptr + 384;

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

        int num_nnz = 8;
        printf("\ninput initialization\n");
        clock_gettime(CLOCK_MONOTONIC, &begin0);

        __fp16 in_vector[16] = {1, 3.1, 31, 0.41, 0.18, 6.31, 3, 8, 0, 1.2, 57.1, 31.3, 4.1, 1.2, 75, 31};

        __fp16 mat_vector[8] = {1.03, 5.2, 7, 3.1, 10, 2, 9, 7};

        uint8_t row_ptr[32] = {0, 0, 1, 2, 2, 2, 2, 3, 3, 4, 4, 5, 6, 6, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        uint8_t col_idx[4] = {0x30, 0x75, 0xdb, 0xfe};

        clock_gettime(CLOCK_MONOTONIC, &end0);
        printf("\nin_vector:\n");

        for(i=0; i<16; i++)
        {
                printf("%f  ", *(in_vector + i));
        }

        printf("\nmat_vector:\n");

        for(i=0; i <num_nnz; i++)
        {
                printf("%f  ", *(mat_vector + i));
        }

        printf("\nrow_ptr:\n");

        for(i=0; i<17; i++)
        {
                printf("%d  ", *(row_ptr + i));
        }

        printf("\ncol_idx:\n");
        for(i=0; i<num_nnz/2; i++)
        {
                printf("%x  ", *(col_idx  + i));
        }

        clock_gettime(CLOCK_MONOTONIC, &begin1);

        clock_gettime(CLOCK_MONOTONIC, &end1);

        printf("\nSW end\n");

        //////////////////////////////////////////////////////////////////////////////

        //// HW matrix multiplication ///////////////////////////////////////////////
        printf("\nresult_before_memcpy:\n");
        for(i=0; i<512; i++)
        {
                printf("%d  ", *(onchip_ptr + i));
        }

        printf("\ninput copy to onchip M10K memory\n");
        clock_gettime(CLOCK_MONOTONIC, &begin2);
        memcpy(in_vector_ptr, in_vector, 16*sizeof(__fp16));
        memcpy(mat_vector_ptr, mat_vector, 8*sizeof(__fp16));
        memcpy(row_ptr_ptr, row_ptr, 32*sizeof(uint8_t));
        memcpy(col_idx_ptr, col_idx, 4*sizeof(uint8_t));
        clock_gettime(CLOCK_MONOTONIC, &end2);

        printf("\nresul_after_memcpy:\n");
        for(i=0; i<512; i++)
        {
                printf("%d  ", *(onchip_ptr + i));
        }

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


        printf("\nresult:\n");
        for(i=0; i<512; i++)
        {
                printf("%d  ", *(onchip_ptr + i));
        }

//      // COMPARE OUTPUT
//      for(i=0; i<8; i++)
//      {
//              for(j=0; j<8; j++)
//              {
//                      if(*(result_ptr + i*8 + j) != result_sw[i*8+j])
//                      {
//                              test = 1;
//                      }
//              }
//      }

        test = 1;

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

