//
// ZAiBModule.swift
// Copyright R&D Computer System Co., Ltd.


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

import Foundation
import UIKit

@objc(ZAiBModule)
class ZAiBModule: NSObject ,ReaderInterfaceDelegate {
  
  func readerInterfaceDidChange(_ attached: Bool) {
    
  }
  
  func cardInterfaceDidDetach(_ attached: Bool) {
    
  }
  
  fileprivate var mNiOS : NiOS?
  fileprivate var mZI : ZI?
  var myObject : NiOS?
  private var mReaderFtInterface : ReaderInterface?
  
  fileprivate var tempParameter_OpenLib : NSString?
  fileprivate var tempParameter_aKey : NSString?
  fileprivate var readerSelect: String?

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  override init() {
    super.init()
    
    mNiOS = NiOS()
    
    mZI = ZI()
    
    mNiOS?.closeLibNi()
    
    mReaderFtInterface = ReaderInterface();
    mReaderFtInterface?.setDelegate(self);
  }
  
  fileprivate var tempcallBack : RCTPromiseResolveBlock?

  @objc func getFilesDirBM(_ resolve: RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)) -> Void {
    
    var libpath: [String];
    var path: String;
    libpath = NSSearchPathForDirectoriesInDomains( FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
    
    path = libpath[0] + "";
    
    resolve(path);
    
  }
  
  
  @objc func openLibBM(_ Parameter_OpenLib: NSString ,resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempParameter_OpenLib = Parameter_OpenLib
    
    self.tempcallBack = resolve;
    
    OpenLibraryThread();

  }

  @objc func getReaderListBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    GetReaderListThread();
  }
  
  @objc func selectReaderBM(_ textReaderName: NSString , resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.readerSelect = textReaderName as String;
    
    self.tempcallBack = resolve;

    SelectReaderThread();
    
  }
  
  @objc func getReaderInfoBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempcallBack = resolve;

    GetReaderInfoThread();
    
  }
  
  @objc func getReaderIDBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempcallBack = resolve;

    GetReaderIDThread();
    
  }
  
  @objc func connectCardBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempcallBack = resolve;

    ConnectCardThread();
    
  }
  
  
  @objc func disconnectCardBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    DisconnectCardThread();
    
  }
  
  @objc func getTextBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    GetTextThread();
    
  }

  @objc func getSTextBM(_ aKey: NSString, resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempParameter_aKey = aKey;
    
    self.tempcallBack = resolve;
    
    GetSTextThread();
    
  }
  
  @objc func getPhotoBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    GetPhotoThread();
    
  }
  
  @objc func getNIDNumberBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempcallBack = resolve;

    GetNIDNumberThread();
    
  }
  
  @objc func updateLicenseFileBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempcallBack = resolve;

    UpdateLicenseThread();

  }

  @objc func getCardStatusBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    GetCardStatusThread();

  }

  @objc func deselectReaderBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    DeselectReaderThread();

  }

  @objc func closeLibBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    CloseLibThread();

  }

  @objc func getLicenseInfoBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){

    self.tempcallBack = resolve;

    GetLicenseInfoThread();
    
  }
  
  @objc func getSoftwareInfoBM(_ resolve: @escaping RCTPromiseResolveBlock, Failed reject: (RCTPromiseRejectBlock)){
    
    self.tempcallBack = resolve;

    GetSoftwareInfoThread();
    
  }
  
  // ============================================= Function ================================================ //
  
  
  @objc func OpenLibraryThread() {
    
    var LICpath  : NSMutableString
    LICpath =  self.tempParameter_OpenLib!.mutableCopy() as! NSMutableString;
    
    var res :Int32?;
    res = mNiOS?.openLibNi(LICpath)
    
    if res != 0 {
      if(res == NI_LICENSE_FILE_ERROR /*-12*/) {
        //FLVL_OPENLIB_MODE
        res = mNiOS?.updateLicenseFileNi()
        
      }
    }
    
    self.tempcallBack?(res);
    
  }
  
  @objc func GetReaderListThread() {
      
      var str_result :String?;
      let readerList :NSMutableArray=NSMutableArray();
      var res :Int32?;
      res =  mNiOS?.getReaderListNi(readerList);
      
      str_result = String( format: "%d;" , res!);
      
      if(res > 0){
          str_result = String( format: "%d;%@" ,res! , readerList[0] as! String );
      }

      self.tempcallBack?(str_result);
  }
  
  @objc func SelectReaderThread() {
      
      var res :Int32?;
      res = mNiOS?.selectReaderNi( self.readerSelect as? NSMutableString);

      self.tempcallBack?(res);
     
  }
  
  @objc func GetReaderInfoThread() {
      
      var str_result :String?;
      let nsData = NSMutableString.init()
      let res : Int32 = (mNiOS?.getReaderInfoNi(nsData))!
      
      if res != 0 {
          str_result = String(format: "%d;"  , NI_READER_NOT_FOUND)
      }else{
          str_result = String(format: "%d;%@" , NI_SUCCESS, nsData )
      }

      self.tempcallBack?(str_result);
      
  }
  
  @objc func GetReaderIDThread() {
      
      var str_result :String?;
      let  RIDBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
      RIDBuffer.initialize(to: 0)
      let iRetRidNi = mNiOS?.getRidNi( RIDBuffer)
      if(iRetRidNi==16) {
          
          var strFTlib: [UInt8] = []
          
          for i in 0..<16 {
              strFTlib.append(UInt8( RIDBuffer[i] ))
          }
          
          let data = NSData(bytes: strFTlib, length: strFTlib.count)
          
          let encoded = data.base64EncodedString()
          
          str_result =  String(format: "%d;%@" , iRetRidNi!, encoded )
      }
      else {
          str_result = String(format: "%d;",iRetRidNi!)
      }
      
      self.tempcallBack?(str_result);
  }
  
  @objc func ConnectCardThread() {

      let res : Int32?;
      res = mNiOS?.connectCardNi();

      self.tempcallBack?(res);
  }
  
  @objc func DisconnectCardThread() {

      let res : Int32?;
      res = mNiOS?.disconnectCardNi();

      self.tempcallBack?(res);
  }
  
  @objc func GetTextThread() {
      
      var str_result :String?;
      let res : Int32?;
      let nsData: NSMutableString = NSMutableString()
      // res = mNiOS?.getATextNi(nsData)
      res = mNiOS?.getNIDTextNi(nsData)
      
      str_result = String(format: "%d;%@",res!,nsData)
      
      self.tempcallBack?(str_result);
  }

    @objc func GetSTextThread() {

        var str_result :String?;
        let nsZiData = NSMutableString.init();
        let nsMutKey =  self.tempParameter_aKey!.mutableCopy() as! NSMutableString;
        let res : Int32 = (mZI?.getSTextZI(mNiOS , nsMutKey, nsZiData))!
        str_result = String(format: "%d;%@",res,nsZiData)

        self.tempcallBack?(str_result);

    }
  
  @objc func GetPhotoThread() {
      
      var str_result :String?;
      let res : Int32?;
      let dataPhoto = NSMutableData.init();
      res = mNiOS?.getNIDPhotoNi(dataPhoto)
      
      let encoded = dataPhoto.base64EncodedString()
      
      str_result = String(format: "%d;%@",res!,encoded)
      
      self.tempcallBack?(str_result);
  }

  @objc func GetNIDNumberThread() {
      
      var str_result :String?;
      let res : Int32?;
      let nsData: NSMutableString = NSMutableString()
      res = mNiOS?.getNIDNumberNi(nsData);
      
      str_result = String(format: "%d;%@",res!,nsData)
      
      self.tempcallBack?(str_result);
  }
  
  @objc func UpdateLicenseThread() {
      
      var res : Int32?;
      res = mNiOS?.updateLicenseFileNi();
      
      if(res == NI_LICENSE_UPDATE_ERROR){
          res = mNiOS?.updateLicenseFileNi();
      }

      self.tempcallBack?(res);
  }
  
  @objc func GetCardStatusThread() {
      
      let res : Int32?;
      res = mNiOS?.getCardStatusNi()
      
      self.tempcallBack?(res);
      
  }
  
  @objc func DeselectReaderThread() {
      
      let res : Int32?;
      res = mNiOS?.deselectReaderNi();
      
      self.tempcallBack?(res);
  }
  
  @objc func CloseLibThread() {
      
      let res : Int32?;
      res = mNiOS?.closeLibNi();

      self.tempcallBack?(res);
      
  }
  
  @objc func GetLicenseInfoThread() {
      
      var _ :[ String];
      let Lic = NSMutableString.init();
      
      _ = mNiOS?.getLicenseInfoNi(Lic);

      self.tempcallBack?(Lic);
      
  }
  
  @objc func GetSoftwareInfoThread() {
    
    let sInfoNi = NSMutableString.init();
    _ = mNiOS?.getSoftwareInfoNi(sInfoNi)

    let sInfoZi = NSMutableString.init();
    _ = mZI?.getSoftwareInfoZI(mNiOS,sInfoZi)
    
    let str_result :String = String(format: "%@/%@",sInfoNi,sInfoZi)
    
    //DispatchQueue.main.async(execute: { () -> Void in
    //  self.tempcallBack?([NSNull(),str_result]);
    //})

    self.tempcallBack?(str_result);
    
  }
  // ===================================================================================================================== //

  func _getFTDevVer(hContext: UInt32, firmware:inout String , hardware:inout String ) -> Int {
      
      var iRet: Int
      firmware = "";
      hardware = "";
      
      let firmwareRevision = UnsafeMutablePointer<Int8>.allocate(capacity: 100)
      firmwareRevision.initialize(to: 0)
      
      let hardwareRevision = UnsafeMutablePointer<Int8>.allocate(capacity: 100)
      hardwareRevision.initialize(to: 0)
      
      
      iRet = Int(FtGetDevVer( SCARDCONTEXT((hContext)), firmwareRevision, hardwareRevision))
      if(iRet==0)
      {
          firmware = String(validatingUTF8: UnsafePointer<CChar>(firmwareRevision))!
          hardware = String(validatingUTF8: UnsafePointer<CChar>(hardwareRevision))!
      }
      
      return iRet
  }
  
  func _getFTSerialNum(SN:inout String  ) -> Int {
      var iRet: Int
      SN = "";
      
      let  buf = UnsafeMutablePointer<Int8>.allocate(capacity: 200)
      buf.initialize(to: 0)
      iRet = Int( FtGetSerialNum(0,100, buf) );
      if( iRet == 0)
      {
          SN = String(validatingUTF8: UnsafePointer<CChar>(buf))!
      }
      return iRet
  }
  
}

