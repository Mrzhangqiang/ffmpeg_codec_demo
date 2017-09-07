//
//  ViewController.m
//  ffmpeg_codec_demo
//
//  Created by jiang on 2017/9/6.
//  Copyright © 2017年 t. All rights reserved.
//

#import "ViewController.h"
#import "TTSwH264Decoder.h"
#import "TTHwH264Decoder.h"

#define FILE_BUF_SIZE       4096

@interface ViewController () <TTVideoDecodingDelegate>
{
    uint8_t *_filebuf;        //读入文件缓存
    dispatch_queue_t _serialQueue;
}

@property (nonatomic, strong) id<TTVideoDecoding> decoder;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 240, 320)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _serialQueue = dispatch_queue_create("com.video.decodequeue", NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"h264"];
        FILE *fp = fopen([filePath UTF8String], "rb");
        if (!fp) {
            fprintf(stderr, "Could not open file\n");
            return;
        }
        _filebuf = malloc(FILE_BUF_SIZE);
        
        //hw
//        _decoder = [[TTHwH264Decoder alloc] init];
//        [_decoder setDelegate:self];
        //sw
        _decoder = [[TTSwH264Decoder alloc] init];
        [_decoder setDelegate:self];
        
        int nDataLen = 0;
        while (true) {
            nDataLen = (int)fread(_filebuf, 1, FILE_BUF_SIZE, fp);
            if (nDataLen <= 0) {
                fclose(fp);
                break;
            } else {
                [_decoder decode:_filebuf length:nDataLen];
            }
        }
        
        free(_filebuf);
        fclose(fp);
    });
}

- (void)videoDecoder:(id)decoder videoFrame:(id)frame {
    self.imageView.image = frame;
}

- (void)videoDecoder:(id)decoder pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
}

#pragma mark - test
//// only for test , in production env use yuv for OpenGL ES
//+ (UIImage*)pixelBufferToImage:(CVPixelBufferRef) pixelBufffer{
//    if (!pixelBufffer) {
//        return nil;
//    }
//    
////    kCVPixelFormatType_24RGB for test
//    CVPixelBufferLockBaseAddress(pixelBufffer, 0);// 锁定pixel buffer的基地址
//    void * baseAddress = CVPixelBufferGetBaseAddress(pixelBufffer);// 得到pixel buffer的基地址
//    size_t width = CVPixelBufferGetWidth(pixelBufffer);
//    size_t height = CVPixelBufferGetHeight(pixelBufffer);
//    size_t bufferSize = CVPixelBufferGetDataSize(pixelBufffer);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBufffer);// 得到pixel buffer的行字节数
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();// 创建一个依赖于设备的RGB颜色空间
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
//    
//    CGImageRef cgImage = CGImageCreate(width,
//                                       height,
//                                       8,
//                                       3 * 8,       //kCVPixelFormatType_24RGB
//                                       bytesPerRow,
//                                       rgbColorSpace,
//                                       kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault,
//                                       provider,
//                                       NULL,
//                                       true,
//                                       kCGRenderingIntentDefault);//这个是建立一个CGImageRef对象的函数
//    
//    UIImage *image = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);  //类似这些CG...Ref 在使用完以后都是需要release的，不然内存会有问题
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(rgbColorSpace);
//    NSData* imageData = UIImageJPEGRepresentation(image, 1.0);//1代表图片是否压缩
//    image = [UIImage imageWithData:imageData];
//    CVPixelBufferUnlockBaseAddress(pixelBufffer, 0);   // 解锁pixel buffer
//    
//    return image;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end