#include <stdbool.h>

#define NM n * m
#define NM3 n * m * sizeof (pixel)
#define M3PLUS3 3 * m + 3

typedef struct {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    int sum;
} pixel;


void smoothBlur(int dim, pixel *src, char *c) {
    int end = dim - 1, i, j, k;
    ++src;
    pixel *pixel1, *pixel2, *pixel3, *pixel4, *pixel5, *pixel6, *pixel7, *pixel8, *pixel9;
    int sumRed1, sumRed2, sumRed3, sumGreen1, sumGreen2, sumGreen3, sumBlue1, sumBlue2, sumBlue3;

    for (i = 1; i < end; ++i) {

        pixel1 = src - 1;
        pixel2 = src;
        pixel3 = src + 1;
        pixel4 = pixel1 + dim;
        pixel5 = pixel4 + 1;
        pixel6 = pixel5 + 1;
        pixel7 = pixel4 + dim;
        pixel8 = pixel7 + 1;
        pixel9 = pixel8 + 1;

        sumRed1 = pixel1->red + pixel4->red + pixel7->red;
        sumRed2 = pixel2->red + pixel5->red + pixel8->red;
        sumRed3 = pixel3->red + pixel6->red + pixel9->red;
        sumGreen1 = pixel1->green + pixel4->green + pixel7->green;
        sumGreen2 = pixel2->green + pixel5->green + pixel8->green;
        sumGreen3 = pixel3->green + pixel6->green + pixel9->green;
        sumBlue1 = pixel1->blue + pixel4->blue + pixel7->blue;
        sumBlue2 = pixel2->blue + pixel5->blue + pixel8->blue;
        sumBlue3 = pixel3->blue + pixel6->blue + pixel9->blue;

        for (j = 1; j < end - 2; j+=3) {

            *c = (char)((sumRed1 + sumRed2 + sumRed3) / 9);
            c++;
            *c = (char)((sumGreen1 + sumGreen2 + sumGreen3) / 9);
            c++;
            *c = (char)((sumBlue1 + sumBlue2 + sumBlue3) / 9);
            c++;

            pixel1 = pixel3 + 1;
            pixel4 = pixel6 + 1;
            pixel7 = pixel9 + 1;

            sumRed1 = sumRed2;
            sumRed2 = sumRed3;
            sumRed3 = pixel1->red + pixel4->red + pixel7->red;
            sumGreen1 = sumGreen2;
            sumGreen2 = sumGreen3;
            sumGreen3 = pixel1->green + pixel4->green + pixel7->green;
            sumBlue1 = sumBlue2;
            sumBlue2 = sumBlue3;
            sumBlue3 = pixel1->blue + pixel4->blue + pixel7->blue;

            *c = (char)((sumRed1 + sumRed2 + sumRed3) / 9);
            c++;
            *c = (char)((sumGreen1 + sumGreen2 + sumGreen3) / 9);
            c++;
            *c = (char)((sumBlue1 + sumBlue2 + sumBlue3) / 9);
            c++;

            pixel2 = pixel1 + 1;
            pixel5 = pixel4 + 1;
            pixel8 = pixel7 + 1;

            sumRed1 = sumRed2;
            sumRed2 = sumRed3;
            sumRed3 = pixel2->red + pixel5->red + pixel8->red;
            sumGreen1 = sumGreen2;
            sumGreen2 = sumGreen3;
            sumGreen3 = pixel2->green + pixel5->green + pixel8->green;
            sumBlue1 = sumBlue2;
            sumBlue2 = sumBlue3;
            sumBlue3 = pixel2->blue + pixel5->blue + pixel8->blue;

            *c = (char)((sumRed1 + sumRed2 + sumRed3) / 9);
            c++;
            *c = (char)((sumGreen1 + sumGreen2 + sumGreen3) / 9);
            c++;
            *c = (char)((sumBlue1 + sumBlue2 + sumBlue3) / 9);
            c++;

            pixel3 = pixel2 + 1;
            pixel6 = pixel5 + 1;
            pixel9 = pixel8 + 1;

            sumRed1 = sumRed2;
            sumRed2 = sumRed3;
            sumRed3 = pixel3->red + pixel6->red + pixel9->red;
            sumGreen1 = sumGreen2;
            sumGreen2 = sumGreen3;
            sumGreen3 = pixel3->green + pixel6->green + pixel9->green;
            sumBlue1 = sumBlue2;
            sumBlue2 = sumBlue3;
            sumBlue3 = pixel3->blue + pixel6->blue + pixel9->blue;
        }

        for (k = j; k < end; ++k) {/*
            *c = (char)((src - 1)->red + src->red + (src + 1)->red + (pixel2 - 1)->red + pixel2->red +
                        (pixel2 + 1)->red + (pixel3 - 1)->red + pixel3->red + (pixel3 + 1)->red) / 9;
            c++;
            *c = (char)((src - 1)->green + src->green + (src + 1)->green + (pixel2 - 1)->green + pixel2->green +
                        (pixel2 + 1)->green + (pixel3 - 1)->green + pixel3->green + (pixel3 + 1)->green) / 9;
            c++;
            *c = (char)((src - 1)->blue + src->blue + (src + 1)->blue + (pixel2 - 1)->blue + pixel2->blue +
                        (pixel2 + 1)->blue + (pixel3 - 1)->blue + pixel3->blue + (pixel3 + 1)->blue) / 9;
            c++;*/
        }
        src += dim;
        c += 6;
    }
}

/*
* Apply the kernel over each pixel.
* Ignore pixels where the kernel exceeds bounds. These are pixels with row index smaller than kernelSize/2 and/or
* column index smaller than kernelSize/2
*/
void smoothSharp(int dim, pixel *src, char *c) {
    int end = dim - 1, i, j;
    ++src;
    pixel *pixel2, *pixel3;

    for (i = 1; i < end; ++i) {
        for (j = 1; j < end; ++j) {
            pixel2 = src + dim;
            pixel3 = pixel2 + dim;

            int red = - ((src - 1)->red + src->red + (src + 1)->red + (pixel2 - 1)->red -9 * pixel2->red +
                         (pixel2 + 1)->red + (pixel3 - 1)->red + pixel3->red + (pixel3 + 1)->red);
            if (red < 0)
                *c = 0;
            else if (red <= 255)
                *c = red;
            else
                *c = 255;
            ++c;

            int green = - ((src - 1)->green + src->green + (src + 1)->green + (pixel2 - 1)->green -9 * pixel2->green +
                           (pixel2 + 1)->green + (pixel3 - 1)->green + pixel3->green + (pixel3 + 1)->green);
            if (green < 0)
                *c = 0;
            else if (green <= 255)
                *c = green;
            else
                *c = 255;

            ++c;

            int blue = - ((src - 1)->blue + src->blue + (src + 1)->blue + (pixel2 - 1)->blue -9 * pixel2->blue +
                          (pixel2 + 1)->blue + (pixel3 - 1)->blue + pixel3->blue + (pixel3 + 1)->blue);
            if (blue < 0)
                *c = 0;
            else if (blue <= 255)
                *c = blue;
            else
                *c = 255;
            ++c;
            ++src;
        }
        src += 2;
        c += 6;
    }
}

void smoothBlurFilter(int dim, pixel *src, char *c) {
    int end = dim - 1, i, j, min_intensity, max_intensity, red, green, blue;
    ++src;

    pixel *helpSum = src + dim;
    for (i = 1; i < end; i++) {
        for (j = 1; j < end; j++) {
            helpSum->sum = helpSum->red + helpSum->green + helpSum->blue;
            ++helpSum;
        }
        helpSum += 2;
    }

    pixel *pixel1, *pixel2, *pixel3, *pixel4, *pixel5, *pixel6, *pixel7, *pixel8, *pixel9, *minp, *maxp;
    int sumRed1, sumRed2, sumRed3, sumGreen1, sumGreen2, sumGreen3, sumBlue1, sumBlue2, sumBlue3;

    for (i = 1; i < end; i++) {

        for (j = 1; j < end; j++) {
            pixel1 = src - 1;
            pixel2 = src;
            pixel3 = src + 1;
            pixel4 = pixel1 + dim;
            pixel5 = pixel4 + 1;
            pixel6 = pixel5 + 1;
            pixel7 = pixel4 + dim;
            pixel8 = pixel7 + 1;
            pixel9 = pixel8 + 1;

            sumRed1 = pixel1->red + pixel4->red + pixel7->red;
            sumRed2 = pixel2->red + pixel5->red + pixel8->red;
            sumRed3 = pixel3->red + pixel6->red + pixel9->red;
            red = (sumRed1 + sumRed2 + sumRed3);

            sumGreen1 = pixel1->green + pixel4->green + pixel7->green;
            sumGreen2 = pixel2->green + pixel5->green + pixel8->green;
            sumGreen3 = pixel3->green + pixel6->green + pixel9->green;
            green = (sumGreen1 + sumGreen2 + sumGreen3);

            sumBlue1 = pixel1->blue + pixel4->blue + pixel7->blue;
            sumBlue2 = pixel2->blue + pixel5->blue + pixel8->blue;
            sumBlue3 = pixel3->blue + pixel6->blue + pixel9->blue;
            blue = (sumBlue1 + sumBlue2 + sumBlue3);

            min_intensity = pixel1->sum;
            max_intensity = pixel1->sum;
            minp = pixel1;
            maxp = pixel1;

            if (pixel2->sum <= min_intensity) {
                min_intensity = pixel2->sum;
                minp = pixel2;
            }
            if (pixel2->sum > max_intensity) {
                max_intensity = pixel2->sum;
                maxp = pixel2;
            }

            if (pixel3->sum <= min_intensity) {
                min_intensity = pixel3->sum;
                minp = pixel3;
            }
            if (pixel3->sum > max_intensity) {
                max_intensity = pixel3->sum;
                maxp = pixel3;
            }

            if (pixel4->sum <= min_intensity) {
                min_intensity = pixel4->sum;
                minp = pixel4;
            }
            if (pixel4->sum > max_intensity) {
                max_intensity = pixel4->sum;
                maxp = pixel4;
            }

            if (pixel5->sum <= min_intensity) {
                min_intensity = pixel5->sum;
                minp = pixel5;
            }
            if (pixel5->sum > max_intensity) {
                max_intensity = pixel5->sum;
                maxp = pixel5;
            }

            if (pixel6->sum <= min_intensity) {
                min_intensity = pixel6->sum;
                minp = pixel6;
            }
            if (pixel6->sum > max_intensity) {
                max_intensity = pixel6->sum;
                maxp = pixel6;
            }

            if (pixel7->sum <= min_intensity) {
                min_intensity = pixel7->sum;
                minp = pixel7;
            }
            if (pixel7->sum > max_intensity) {
                max_intensity = pixel7->sum;
                maxp = pixel7;
            }

            if (pixel8->sum <= min_intensity) {
                min_intensity = pixel8->sum;
                minp = pixel8;
            }
            if (pixel8->sum > max_intensity) {
                max_intensity = pixel8->sum;
                maxp = pixel8;
            }

            if (pixel9->sum <= min_intensity)
                minp = pixel9;
            if (pixel9->sum > max_intensity)
                maxp = pixel9;


            // divide by kernel's weight
            red = (red - minp->red - maxp->red) / 7;
            green = (green - minp->green - maxp->green) / 7;
            blue = (blue - minp->blue - maxp->blue) / 7;

            // truncate each pixel's color values to match the range [0,255]
            if (red <= 255)
                *c = red;
            else
                *c = 255;
            ++c;

            if (green <= 255)
                *c = green;
            else
                *c = 255;
            ++c;

            if (blue <= 255)
                *c = blue;
            else
                *c = 255;
            ++c;
            ++src;
        }
        src += 2;
        c += 6;
    }
}

void charsToPixels(Image *charsImg, pixel* pixels) {
    char *data = image->data;
    int row, i;
    for (row = 0; row < NM - 3; row+=4) {
        pixels->red = *(data++);
        pixels->green = *(data++);
        pixels->blue = *(data++);
        ++pixels;
        pixels->red = *(data++);
        pixels->green = *(data++);
        pixels->blue = *(data++);
        ++pixels;
        pixels->red = *(data++);
        pixels->green = *(data++);
        pixels->blue = *(data++);
        ++pixels;
        pixels->red = *(data++);
        pixels->green = *(data++);
        pixels->blue = *(data++);
        ++pixels;
    }
    for (i = row; i < NM; ++i) {
        pixels->red = *(data++);
        pixels->green = *(data++);
        pixels->blue = *(data++);
        ++pixels;
    }
}



void myfunction(Image *image, char* srcImgpName, char* blurRsltImgName, char* sharpRsltImgName, char* filteredBlurRsltImgName, char* filteredSharpRsltImgName, char flag) {

    pixel *backupOrg = malloc(NM3);
    charsToPixels(image, backupOrg);
    char *c = image->data + M3PLUS3;

    if (flag =='1') {
        smoothBlur(m, backupOrg, c);
        charsToPixels(image, backupOrg);
        writeBMP(image, srcImgpName, blurRsltImgName);
        smoothSharp(m, backupOrg, c);
        writeBMP(image, srcImgpName, sharpRsltImgName);
    } else {
        smoothBlurFilter(m, backupOrg, c);
        charsToPixels(image, backupOrg);
        writeBMP(image, srcImgpName, filteredBlurRsltImgName);
        smoothSharp(m, backupOrg, c);
        writeBMP(image, srcImgpName, filteredSharpRsltImgName);
    }
    free(backupOrg);
}
