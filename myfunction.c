#include <stdbool.h>

#define NM n * m
#define NM3 n * m * sizeof (pixel)

typedef struct {
    int red;
    int green;
    int blue;
} pixel_sum;

typedef struct {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    int sum;
} pixel;

/*
 *  Applies kernel for pixel at (i,j)
 */
static pixel SharpKernel(int dim, pixel *src, pixel *dst) {

    pixel *pixel2 = src + dim;
    pixel *pixel3 = pixel2 + dim;

    int red = - ((src - 1)->red + src->red + (src + 1)->red + (pixel2 - 1)->red -9 * pixel2->red +
                   (pixel2 + 1)->red + (pixel3 - 1)->red + pixel3->red + (pixel3 + 1)->red);
    int green = - ((src - 1)->green + src->green + (src + 1)->green + (pixel2 - 1)->green -9 * pixel2->green +
                     (pixel2 + 1)->green + (pixel3 - 1)->green + pixel3->green + (pixel3 + 1)->green);
    int blue = - ((src - 1)->blue + src->blue + (src + 1)->blue + (pixel2 - 1)->blue -9 * pixel2->blue +
                    (pixel2 + 1)->blue + (pixel3 - 1)->blue + pixel3->blue + (pixel3 + 1)->blue);

    if (red < 0)
        dst->red = 0;
    else if (red <= 255)
        dst->red = red;
    else
        dst->red = 255;
    if (green < 0)
        dst->green = 0;
    else if (green <= 255)
        dst->green = green;
    else
        dst->green = 255;
    if (blue < 0)
        dst->blue = 0;
    else if (blue <= 255)
        dst->blue = blue;
    else
        dst->blue = 255;
}

static pixel blurKernel(int dim, pixel *src, pixel *dst) {

    pixel *pixel2 = src + dim;
    pixel *pixel3 = pixel2 + dim;

    dst->red = ((src - 1)->red + src->red + (src + 1)->red + (pixel2 - 1)->red + pixel2->red +
                         (pixel2 + 1)->red + (pixel3 - 1)->red + pixel3->red + (pixel3 + 1)->red) / 9;
    dst->green = ((src - 1)->green + src->green + (src + 1)->green + (pixel2 - 1)->green + pixel2->green +
                           (pixel2 + 1)->green + (pixel3 - 1)->green + pixel3->green + (pixel3 + 1)->green) / 9;
    dst->blue = ((src - 1)->blue + src->blue + (src + 1)->blue + (pixel2 - 1)->blue + pixel2->blue +
                          (pixel2 + 1)->blue + (pixel3 - 1)->blue + pixel3->blue + (pixel3 + 1)->blue) / 9;
}

static pixel blurKernelFilter(int dim, pixel *src, pixel *dst) {

    pixel *pixel2 = src + dim;
    pixel *pixel3 = pixel2 + dim;

    int red = ((src - 1)->red + src->red + (src + 1)->red + (pixel2 - 1)->red + pixel2->red +
               (pixel2 + 1)->red + (pixel3 - 1)->red + pixel3->red + (pixel3 + 1)->red);
    int green = ((src - 1)->green + src->green + (src + 1)->green + (pixel2 - 1)->green + pixel2->green +
                 (pixel2 + 1)->green + (pixel3 - 1)->green + pixel3->green + (pixel3 + 1)->green);
    int blue = ((src - 1)->blue + src->blue + (src + 1)->blue + (pixel2 - 1)->blue + pixel2->blue +
                (pixel2 + 1)->blue + (pixel3 - 1)->blue + pixel3->blue + (pixel3 + 1)->blue);

    int min_intensity = (src - 1)->sum;
    int max_intensity = (src - 1)->sum;
    pixel *minp = (src - 1);
    pixel *maxp = (src - 1);

    if (src->sum <= min_intensity) {
        min_intensity = src->sum;
        minp = src;
    }
    if (src->sum > max_intensity) {
        max_intensity = src->sum;
        maxp = src;
    }

    if ((src + 1)->sum <= min_intensity) {
        min_intensity = (src + 1)->sum;
        minp = (src + 1);
    }
    if ((src + 1)->sum > max_intensity) {
        max_intensity = (src + 1)->sum;
        maxp = (src + 1);
    }

    if ((pixel2 - 1)->sum <= min_intensity) {
        min_intensity = (pixel2 - 1)->sum;
        minp = (pixel2 - 1);
    }
    if ((pixel2 - 1)->sum > max_intensity) {
        max_intensity = (pixel2 - 1)->sum;
        maxp = (pixel2 - 1);
    }

    if (pixel2->sum <= min_intensity) {
        min_intensity = pixel2->sum;
        minp = pixel2;
    }
    if (pixel2->sum > max_intensity) {
        max_intensity = pixel2->sum;
        maxp = pixel2;
    }

    if ((pixel2 + 1)->sum <= min_intensity) {
        min_intensity = (pixel2 + 1)->sum;
        minp = (pixel2 + 1);
    }
    if ((pixel2 + 1)->sum > max_intensity) {
        max_intensity = (pixel2 + 1)->sum;
        maxp = (pixel2 + 1);
    }

    if ((pixel3 - 1)->sum <= min_intensity) {
        min_intensity = (pixel3 - 1)->sum;
        minp = (pixel3 - 1);
    }
    if ((pixel3 - 1)->sum > max_intensity) {
        max_intensity = (pixel3 - 1)->sum;
        maxp = (pixel3 - 1);
    }

    if (pixel3->sum <= min_intensity) {
        min_intensity = pixel3->sum;
        minp = pixel3;
    }
    if (pixel3->sum > max_intensity) {
        max_intensity = pixel3->sum;
        maxp = pixel3;
    }

    if ((pixel3 + 1)->sum <= min_intensity)
        minp = (pixel3 + 1);
    if ((pixel3 + 1)->sum > max_intensity)
        maxp = (pixel3 + 1);


    // divide by kernel's weight
    red = (red - minp->red - maxp->red) / 7;
    green = (green - minp->green - maxp->green) / 7;
    blue = (blue - minp->blue - maxp->blue) / 7;

    // truncate each pixel's color values to match the range [0,255]
    if (red <= 255)
        dst->red = red;
    else
        dst->red = 255;
    if (green <= 255)
        dst->green = green;
    else
        dst->green = 255;
    if (blue <= 255)
        dst->blue = blue;
    else
        dst->blue = 255;
}

/*
* Apply the kernel over each pixel.
* Ignore pixels where the kernel exceeds bounds. These are pixels with row index smaller than kernelSize/2 and/or
* column index smaller than kernelSize/2
*/
void smoothSharp(int dim, pixel *src, pixel *dst) {
    int end = dim - 1, i, j;
    dst += dim + 1;
    ++src;

    for (i = 1; i < end; ++i) {
        for (j = 1; j < end; ++j)
            SharpKernel(dim, src++, dst++);
        dst += 2;
        src += 2;
    }
}
void smoothBlur(int dim, pixel *src, pixel *dst) {
    int end = dim - 1, i, j;
    dst += dim + 1;
    ++src;

    for (i = 1; i < end; ++i) {
        for (j = 1; j < end; ++j)
            blurKernel(dim, src++, dst++);
        dst += 2;
        src += 2;
    }
}

void smoothBlurFilter(int dim, pixel *src, pixel *dst) {
    int end = dim - 1, i, j;
    dst += dim + 1;
    ++src;

    pixel *helpSum = src + dim;
    for (i = 1; i < end; ++i) {
        for (j = 1; j < end; ++j)
            (helpSum++)->sum = helpSum->red + helpSum->green + helpSum->blue;
        helpSum += 2;
    }

    for (i = 1; i < end; ++i) {
        for (j = 1; j < end; ++j)
            blurKernelFilter(dim, src++, dst++);
        dst += 2;
        src += 2;
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

void pixelsToChars(pixel* pixels, Image *charsImg) {
    char *data = image->data;
    int row, i;
    for (row = 0; row < NM - 3; row+=4) {
        *(data++) = pixels->red;
        *(data++) = pixels->green;
        *(data++) = pixels->blue;
        ++pixels;
        *(data++) = pixels->red;
        *(data++) = pixels->green;
        *(data++) = pixels->blue;
        ++pixels;
        *(data++) = pixels->red;
        *(data++) = pixels->green;
        *(data++) = pixels->blue;
        ++pixels;
        *(data++) = pixels->red;
        *(data++) = pixels->green;
        *(data++) = pixels->blue;
        ++pixels;
    }
    for (i = row; i < NM; ++i) {
        *(data++) = pixels->red;
        *(data++) = pixels->green;
        *(data++) = pixels->blue;
        ++pixels;
    }
}

void copyPixels(pixel* src, pixel* dst) {
    int row, i;
    for (row = 0 ; row < NM - 3; row+=4) {
        dst->red = src->red;
        dst->green = src->green;
        dst->blue = src->blue;
        ++dst;
        ++src;
        dst->red = src->red;
        dst->green = src->green;
        dst->blue = src->blue;
        ++dst;
        ++src;
        dst->red = src->red;
        dst->green = src->green;
        dst->blue = src->blue;
        ++dst;
        ++src;
        dst->red = src->red;
        dst->green = src->green;
        dst->blue = src->blue;
        ++dst;
        ++src;
    }
    for (i = row; i < NM; ++i) {
        dst->red = src->red;
        dst->green = src->green;
        dst->blue = src->blue;
        ++dst;
        ++src;
    }
}

void doConvolution(Image *image, bool filter, bool blurOrSharp, pixel *backupOrg) {

    // calculate the multiply one time instead of two
    pixel* pixelsImg = malloc(NM3);

    charsToPixels(image, pixelsImg);
    copyPixels(pixelsImg, backupOrg);

    if(blurOrSharp) {
        smoothSharp(m, backupOrg, pixelsImg);
    }
    else {
        if (filter)
            smoothBlurFilter(m, backupOrg, pixelsImg);
        else
            smoothBlur(m, backupOrg, pixelsImg);
    }

    pixelsToChars(pixelsImg, image);

    free(pixelsImg);
}

void myfunction(Image *image, char* srcImgpName, char* blurRsltImgName, char* sharpRsltImgName, char* filteredBlurRsltImgName, char* filteredSharpRsltImgName, char flag) {

    pixel* backupOrg = malloc(NM3);
    if (flag == '1') {
        // blur image
        doConvolution(image, false, false, backupOrg);

        // write result image to file
        writeBMP(image, srcImgpName, blurRsltImgName);

        // sharpen the resulting image
        doConvolution(image, false, true, backupOrg);

        // write result image to file
        writeBMP(image, srcImgpName, sharpRsltImgName);
    } else {
        // apply extermum filtered kernel to blur image
        doConvolution(image, true, false, backupOrg);

        // write result image to file
        writeBMP(image, srcImgpName, filteredBlurRsltImgName);

        // sharpen the resulting image
        doConvolution(image, false, true, backupOrg);

        // write result image to file
        writeBMP(image, srcImgpName, filteredSharpRsltImgName);
    }
    free(backupOrg);
}
