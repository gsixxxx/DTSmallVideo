# DTSmallVideo
SmallVideo, PartialRecord, CombineVideos, Convert as MP4 <br> 
小视频, 分段录制, 合成视频, 导出成MP4<br> 
## Version 1.0.0
    Drag DT-SmallVideoVideoSDK to ProjectDirectory
    把 DT-SmallVideoVideoSDK 拖到工程中

```
DTRecordViewController *recordViewController = [[DTRecordViewController alloc]initRecorViewControllerWithCompleteBlock:^(NSURL *videoSandBoxUrl){ 

  //return combined video SandBox FileUrl
  
}];
[self.navigationController pushViewController:recordViewController animated:YES];
```
## Customization
  Cutomize DTRecordViewController To Change Interface <br>
  更改 DTRecordViewController 自定义录制页面 <br>
  ![image](https://github.com/xxxx.jpg)
