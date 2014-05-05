## iOS 에서 Camera를 이용한 QR Code scanning prototyping 


### 기능 목표  

- 카메라화면을 별도의 View에 띄워 실시간으로 화면을 그려준다. 
- QRCode 를 갖다대면 이를 인식하고 파싱하여 해당 코드스트링을 TextView에 출력한다. 


### 회고 

iOS7.x 에서 기본 내장하고있는 AVFoundationKit 을 이용해서 손쉽게 구현이 가능했다 =ㅅ=a 
게다가 QRCode를 인식하는부분이 ios7.x 오면서 Passbook지원을 위해 이 기능이 OS내부에 내장되었다.  
단지 `AVCaptureMetadataOutputObjectsDelegate`를 사용하는것만으로 날로 비전인식기능을 쓸수있게됐다능
