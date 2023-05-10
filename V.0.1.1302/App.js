// App
// Copyright R&D Computer System Co., Ltd.

import React, { Component } from "react";
import {
  StyleSheet,
  ScrollView,
  View,
  Text,
  NativeModules,
  PermissionsAndroid,
  Platform
} from "react-native";
import RNExitApp from "react-native-exit-app";
import { Buffer } from "buffer";

import { ThemeProvider, Button, Image } from "react-native-elements";
const { ZAiBModule } = NativeModules;

class FirstScreen extends Component {
  constructor() {
    super();

    NA_POPUP                        = 0x80;
    NA_FIRST                        = 0x40;
    NA_SCAN                         = 0x10;
    NA_BLE1                         = 0x08;
    NA_BLE0                         = 0x04;
    NA_BT                           = 0x02;
    NA_USB                          = 0x01;

    NA_SUCCESS                      = 0;
    NA_INTERNAL_ERROR               = -1;
    NA_INVALID_LICENSE              = -2;
    NA_READER_NOT_FOUND             = -3;
    NA_CONNECTION_ERROR             = -4;
    NA_GET_PHOTO_ERROR              = -5;
    NA_GET_TEXT_ERROR               = -6;
    NA_INVALID_CARD                 = -7;
    NA_UNKNOWN_CARD_VERSION         = -8;
    NA_DISCONNECTION_ERROR          = -9;
    NA_INIT_ERROR                   = -10;
    NA_READER_NOT_SUPPORTED         = -11;
    NA_LICENSE_FILE_ERROR           = -12;
    NA_PARAMETERS_ERROR             = -13;
    NA_INTERNET_ERROR               = -15;
    NA_CARD_NOT_FOUND               = -16;
    NA_BLUETOOTH_DISABLED           = -17;
    NA_LICENSE_UPDATE_ERROR         = -18;
    NA_STORAGE_PERMISSION_ERROR     = -31;
    NA_LOCATION_PERMISSION_ERROR    = -32;
    NA_BLUETOOTH_PERMISSION_ERROR   = -33;
    NA_LOCATION_SERVICE_ERROR       = -41;


    AppName                         = "",
    readerName                      = "Reader: ",
    text_result                     = "",
    LicenseInfo                     = "",
    SoftwareInfo                    = "",
    logo_str                        = [];
    base64_code_photo               = "";
    IDcardNumber                    = "";
    headerResult                    = "";
    ButtonView                      = [],
    ImageView                       = [],
    Folder                          = "";
    LICFileName                     = "";
    rootFolder                      = "";
    LicFile                         = "";
    Parameter_OpenLib               = "";
    isReaderConnected               = false;

    logo_str.push(
      <Image
        key="ImageBase"
        source={require("./assets/react_logo.png")}
        style={{ width: 80, height: 80 }}
        containerStyle={{
          marginLeft: "auto",
          marginRight: "auto",
          marginTop: "10%",
          marginBottom: "5%",
        }}
      />
    );

    if(Platform.OS === 'android'){
        // Android-specific code/UI Component
        AppName = "ZAiReact 0.2.1302 (Android)";
    }else if(Platform.OS === 'ios'){
        // iOS-specific code/UI Component
        AppName = "ZAiReact 0.2.1302 (iOS)";
    }

    this.state = {
        AppName: AppName,
        readerName: readerName, 
        text_result: text_result,
        ButtonView : ButtonView,
        ImageView: logo_str,
    };
  }

  componentDidMount(){
    this.DisableButton();
    if(Platform.OS === 'android'){
      // Android-specific code/UI Component
      this.initAndroid();
    }else if(Platform.OS === 'ios'){
      // iOS-specific code/UI Component
      this.initIOS();
    }
  }

  //////////////////////////////// Initialize for Android ////////////////////////////////
  async initAndroid(){
    Folder = "/" + "ZAiReact";
    LICFileName = "/" + "rdnidlib.dls";

    await this.getFilesDirJF();

    if(!await this.setListenerJF()){
      return;
    }
    if(!await this.getSoftwareInfoJF()){
      return;
    }
    if(!await this.writeLicFileJF()){
      return;
    }
    if(!await this.setPermissionsJF()){
      return;
    }
    if(!await this.openLibJF()){
      return;
    }
    if(!await this.getLicenseInfoJF()){
      return;
    }

    this.requestPermission();

    this.EnableButton();
  }

  //////////////////////////////// Initialize for IOS ////////////////////////////////
  async initIOS(){
    Folder = "/" + "ZAiReact";
    LICFileName = "/" + "rdnidlib.dlt";

    await this.getFilesDirJF();

    if(!await this.getSoftwareInfoJF()){
      return;
    }
    if(!await this.openLibJF()){
      return;
    }
    if(!await this.getLicenseInfoJF()){
      return;
    }

    this.EnableButton();
  }

  //////////////////////////////// Button Find Reader ////////////////////////////////
  async buttonFindReader() {
    isReaderConnected = false;
    text_str = "Reader scanning...";
    this.DisableButton();

    this.setState({
      ImageView: logo_str,
      readerName: text_str,
      text_result: "",
    } );

    // ===================== get Reader List ======================== //
    var tempRes = await this.getReaderListJF();
    returnCode = tempRes[0];

    if(tempRes == null)
      return;
    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }
    if (returnCode == 0 || returnCode == -3) {
        this.EnableButton();
        this.setState({
            readerName: 'Reader: ',
            text_result: '-3 Reader not found.',
            ImageView: logo_str,
            ButtonView: ButtonView,
        });

    }else if( returnCode < 0){
        resText = this.checkException(returnCode);
        this.EnableButton();
        this.setState({
            readerName: 'Reader: ',
            text_result: resText,
            ImageView: logo_str,
            ButtonView: ButtonView,
        });
    }else if(returnCode > 0){
      textReaderName = tempRes[1];
      this.setState({
          readerName: "Reader selecting...",
      });

      // ===================== Select Reader ======================== //
      if(await this.selectReaderJF(textReaderName)){
        await this.getReaderInfoJF();
        await this.getLicenseInfoJF();
      }
    }
    this.EnableButton();
  }

  //////////////////////////////// Button Read Card ////////////////////////////////
  async buttonRead() {
    this.DisableButton();
    await this.setState({
      ImageView: logo_str,
      text_result: "Reading...",
      ButtonView: ButtonView,
    });

    if(Platform.OS === 'ios'){
      returnCode = await this.getCardStatusJF();
      if (isNaN(returnCode)) {
        returnCode = Number.parseInt(returnCode);
      }
      text_result = "";
      if (returnCode != 1) {
        text_result = this.checkException(returnCode);
        if( isReaderConnected != true){
            text_result = '-3 Reader not found.';
        }
        this.EnableButton();
        this.setState({
          text_result: text_result,
          ButtonView: ButtonView,
        });
        return;
      }
    }


    // ===================== Connect Card ======================== //
    var startTime = new Date().getTime();
    resConnect = await this.connectCardJF();
    if( resConnect != NA_SUCCESS ){
      text_result = this.checkException(resConnect);
      this.EnableButton();
      this.setState({
        text_result: text_result
      });
      return;
    }

    var returnCode = -1;

    // ===================== Get Text ======================== //
    tempRes = await this.getTextJF();


    var endTime = new Date().getTime();
    Time_ReadText = ( endTime - startTime ) /1000;

    if(tempRes == null)
      returnCode = NA_GET_TEXT_ERROR;
    else{
      returnCode = tempRes[0];
    }

    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }

    if(returnCode != NA_SUCCESS){
      this.setState({
        text_result: this.checkException(returnCode),
      });
      // ===================== Disconnect Card ======================== //
      await this.disconnectCardJF();
      this.EnableButton();
      return;
    }

    resText = tempRes[1];
    text_result = resText;
    this.setState({
      text_result: text_result
    });

    var aKey = "";

    if(Platform.OS === 'android'){
      aKey = resText.substring(2, 5) + resText.substring(9, 11);
    }else if(Platform.OS === 'ios'){
      aKey = resText.substring(10, 12) + resText.substring(2,5);
    }

    // ===================== Get SText ======================== //
    var startSTime = new Date().getTime();
    tempRes = await this.getSTextJF(aKey);


    var endSTime = new Date().getTime();
    Time_ReadSText = ( endSTime - startSTime ) /1000;

    if(tempRes == null)
      returnCode = NA_GET_TEXT_ERROR;
    else{
      returnCode = tempRes[0];
    }

    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }

    if(returnCode != NA_SUCCESS){
      this.setState({
        text_result: this.checkException(returnCode),
      });
      // ===================== Disconnect Card ======================== //
      await this.disconnectCardJF();
      this.EnableButton();
      return;
    }

    resText = tempRes[1];
    text_result += "\n\n" +resText
    + "\n\n" + "Read Text: " + Time_ReadText.toFixed(2) + " s"
    + "\n" + "Read SText: " + Time_ReadSText.toFixed(2) + " s"
    this.setState({
      text_result: text_result
    });

    // ===================== Connect Card ======================== //
    resConnect = await this.connectCardJF();
    if( resConnect != NA_SUCCESS ){
      text_result = this.checkException(resConnect);
      this.EnableButton();
      this.setState({
        text_result: text_result
      });
      return;
    }

    var returnCode = -1;


    // ===================== Get Photo ======================== //
    var tempRes2 = await this.getPhotoJF();
    if(tempRes2 == null)
      returnCode = NA_GET_TEXT_ERROR;
    else{
      returnCode = tempRes2[0];
    }

    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }

    if(returnCode != NA_SUCCESS){
      Image_resText = this.checkException(returnCode);
      if (Image_resText == resText) {
        Image_resText = "";
      }
      text_result = text_result + "\n" + Image_resText;

      this.setState({
        text_result: text_result,
        ImageView: logo_str,
      });
      this.EnableButton();
      // ===================== Disconnect Card ======================== //
      await this.disconnectCardJF();
      return;
    }

    base64_code_photo =  tempRes2[1];

    var base64Image = "data:image/jpeg;base64," + base64_code_photo + "";
    var image_str = [];
    image_str.push(
      <Image
        key="ImageCallback"
        source={{
          uri: base64Image,
        }}
        style={{
          width: 80,
          height: "auto",
          aspectRatio: 1,
          resizeMode: "contain",
        }}
        containerStyle={{
          marginLeft: "auto",
          marginRight: "auto",
          marginTop: "10%",
          marginBottom: "5%",
        }}
      />
    );
    this.setState({
      text_result: text_result,
      ImageView: image_str,
    });
    // ===================== Disconnect Card ======================== //
    await this.disconnectCardJF();
    var endTime = new Date().getTime();
    var Time_ReadPhoto = ( endTime - startTime ) /1000;
    text_result = text_result + "\nRead Text+SText+Photo: "+ Time_ReadPhoto.toFixed(2) + " s"
    this.setState({
      text_result: text_result,
    });
    this.EnableButton();
  }

  //////////////////////////////// Button Get Card Status ////////////////////////////////
  async buttonGetCardStatus(){

    var returnCode = await this.getCardStatusJF();
    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }

    resText = "";
    if (returnCode == 1) {
      resText = "Card Status: Present";
    }else if(returnCode == -16 ){
      resText = "Card Status: Absent (card not found)";
    }else{
      resText = this.checkException(returnCode);
      if(Platform.OS === 'ios'){
          if( isReaderConnected != true){
              resText = '-3 Reader not found.'
          }
      }
    }

    this.EnableButton();
    this.setState({
      text_result: resText,
      ButtonView: ButtonView,
    });
  }

  //////////////////////////////// Button Update License ////////////////////////////////
  async buttonUpdateLicensefile(){
    this.DisableButton();
    await this.setState({
      text_result: "License updating...",
      ImageView: logo_str
    });

    var textLicenseUpdate = "";

    var returnCode = await this.updateLicenseFileJF();

    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }
    if (returnCode == 0 || returnCode == 1 || returnCode == 2 || returnCode == 3 ) {
      textLicenseUpdate = returnCode.toString() + ":The new license file has been successfully updated.";
      this.setState({
        text_result: textLicenseUpdate,
      });
      // ===================== Get License Info ======================== //
      await this.getLicenseInfoJF();
    }else{
      if(returnCode == 100 || returnCode == 101 || returnCode == 102 || returnCode == 103){
        textLicenseUpdate = returnCode.toString() + ": The latest license file has already been installed.";
        // ===================== Get License Info ======================== //
        await this.getLicenseInfoJF();
      }else{
        textLicenseUpdate = this.checkException(returnCode);
      }
    }
    this.EnableButton();
    this.setState({
      text_result: textLicenseUpdate,
      ButtonView: ButtonView,
    });
  }

  //////////////////////////////// Generate RID To String ////////////////////////////////
  async generateRIDToString(){
    result ="";

    var tempRes = await this.getReaderIDJF();
    returnCode = tempRes[0];
    if (isNaN(returnCode)) {
      // if is not a number
      returnCode = Number.parseInt(returnCode);
    }

    if(returnCode > 0){
      number_bytes = returnCode;
      base64_Rid =  tempRes[1];
      let byte_Rid = Buffer.from(base64_Rid, "base64");
      hexString = "";
      for ( i = 0 ; i < number_bytes ; i ++) {
            h = byte_Rid[i].toString(16); // Number to Hex String
        while (h.length < 2){
            h = "0" + h;
        }
        hexString += h + " ";
      }
      textReaderID = hexString.toUpperCase();

    }else if(returnCode < 0 ){
      textReaderID =  this.checkException(returnCode);
    }

    text_result = text_result + "\n\nReader ID: " + textReaderID;

    this.EnableButton();
    this.setState({
      text_result: text_result
    });
  }

  //////////////////////////////// Get File Directory ////////////////////////////////
  async getFilesDirJF(){
      var FilesDirectory = await ZAiBModule.getFilesDirBM();
      rootFolder = FilesDirectory + Folder;                       // you can change path of license files at here
      LicFile = rootFolder + LICFileName ;
      Parameter_OpenLib = LicFile;
  }

  //////////////////////////////// Set Listener ////////////////////////////////
  async setListenerJF(){
    var response = await ZAiBModule.setListenerBM();
    if(response == NA_SUCCESS){
        return true;
    }else{
      this.setState({
        text_result: this.checkException(NA_INTERNAL_ERROR)
      });
      return false;
    }
  }

  //////////////////////////////// Request Permission Function ////////////////////////////////
  async requestPermission(){

    resText = "";
    if(Platform.Version >= 31){
      await  PermissionsAndroid.requestMultiple( [PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT]);
    }else{
      await  PermissionsAndroid.request( PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION);
      if( await PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION ) != true  ){   // BluetoothScan , BluetoothConnect
        resText = resText + "\n\n" + "-32 Location permission error.";
        this.setState({
          text_result: resText
         });
      }
    }
  }

  //////////////////////////////// Write File Function ////////////////////////////////
  async writeLicFileJF() {
    var returnCode = await ZAiBModule.writeLicFileBM(LicFile);
    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }
    if (returnCode == 1) {
      resText = "License file is already has been.";
      this.setState({
        text_result: resText,
      });
      return true;
    } else if (returnCode != 0) {
      resText = "Write License file failed.";
      this.setState({
        text_result: resText,
      });
      return false;
    } else {
      return true;
    }
  }

  //////////////////////////////// Set Permission ////////////////////////////////
  async setPermissionsJF() {
    var pms = 1;
    var returnCode = await ZAiBModule.setPermissionsBM(pms);
    if (isNaN(returnCode)) {
      // if is not a number
      returnCode = Number.parseInt(returnCode);
    }
    if (returnCode < 0) {
      var resText = this.checkException(returnCode);
      this.setState({
        text_result: resText,
      });
      return false;
    }
    return true;
  }

  //////////////////////////////// Open Lib ////////////////////////////////
  async openLibJF() {
    resOpenLib = "";
    var returnCode = await ZAiBModule.openLibBM(Parameter_OpenLib)
    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }
    if (returnCode == NA_SUCCESS) {
      resOpenLib = "Opened the library successfully.";
      await this.setState({
        text_result: resOpenLib,
      });
      return true;
    } else {
      resOpenLib = "Opened the library failed, Please restart app.";
      this.setState({
        text_result: resOpenLib,ƒƒ
      });
      return false;
    }
  }

  //////////////////////////////// get Reader List ////////////////////////////////
  async getReaderListJF () {
    var result;
    if(Platform.OS === 'android'){
      listOption  = NA_POPUP + NA_SCAN + NA_BLE1 + NA_BLE0 + NA_BT + NA_USB; // 0x9F USB & BLE1 & BLE0 &  BT Reader
      if(Platform.Version >= 31){
          if ((listOption & NA_SCAN) != 0 && ((listOption & NA_BT) != 0 || (listOption & NA_BLE0) != 0 || (listOption & NA_BLE1) != 0)) {
            if( await PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN ) != true &&  await PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT ) != true ){
              listOption = listOption - ( NA_SCAN + NA_BLE1 + NA_BLE0  + NA_BT ); //remove BLE1, BLE0, BT Scanning
            }
          }
      }else{
          if ((listOption & NA_SCAN) != 0 && ((listOption & NA_BT) != 0 || (listOption & NA_BLE0) != 0 || (listOption & NA_BLE1) != 0)) {
              if( await PermissionsAndroid.check(PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION ) != true  ){
                listOption = listOption - ( NA_SCAN + NA_BLE1 + NA_BLE0 + NA_BT ); //remove BLE0, BT Scanning
              }
          }
      }
      result = await ZAiBModule.getReaderListBM(listOption);
    }else if(Platform.OS === 'ios'){
      result = await ZAiBModule.getReaderListBM();
    }

    return result.split(";");
  }

  //////////////////////////////// Select Reader ////////////////////////////////
  async selectReaderJF(textReaderName) {
    returnCode = await ZAiBModule.selectReaderBM(textReaderName)
    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }
    if (returnCode != NA_SUCCESS) {
      this.setState({
        text_result: this.checkException(returnCode),
      });
      if (returnCode != NA_INVALID_LICENSE && returnCode != NA_LICENSE_FILE_ERROR) {
        this.EnableButton();
        this.setState({
          ButtonView: ButtonView,
          readerName: "Reader: ",
        });
      }else if(returnCode == NA_INVALID_LICENSE || returnCode == NA_LICENSE_FILE_ERROR) {

        this.EnableButton();
        this.setState({
          ButtonView: ButtonView,
          readerName: 'Reader: ' + textReaderName,
        });
      }
      return false;
    }else if(returnCode == NA_SUCCESS ){
      isReaderConnected = true
      await this.setState({
        readerName: 'Reader: ' + textReaderName,
      });
    }
    return true;
  }

  //////////////////////////////// Get Reader Info ////////////////////////////////
  async getReaderInfoJF() {
    var readerInfo = "";
    var res = await ZAiBModule.getReaderInfoBM();
    var tempRes = res.split(";");
    returnCode = tempRes[0];
    if (isNaN(returnCode)) {
      returnCode = Number.parseInt(returnCode);
    }

    if(returnCode == NA_SUCCESS){
      readerInfo = tempRes[1];
      text_result = "Reader Info: " + readerInfo;
    }else{
      text_result = this.checkException(returnCode);
    }
    await this.setState({
      text_result: text_result,
    });
  }

  //////////////////////////////// Connect Card ////////////////////////////////
  async connectCardJF() {
    res = await ZAiBModule.connectCardBM();
    return res;
  }

  //////////////////////////////// Get NID Number ////////////////////////////////
  async getNIDNumberJF(){
    var res = await ZAiBModule.getNIDNumberBM();
    var tempRes = res.split(";");
    return tempRes;
  }

  //////////////////////////////// Get Text ////////////////////////////////
  async getTextJF(){
    var res = await ZAiBModule.getTextBM();
    var tempRes = res.split(";");
    return tempRes;
  }

  //////////////////////////////// Get SText ////////////////////////////////
  async getSTextJF(aKey){
    var res = await ZAiBModule.getSTextBM(aKey);
    var tempRes = res.split(";");
    return tempRes;
  }

  //////////////////////////////// Get Photo ////////////////////////////////
  async getPhotoJF(){
    var res = await ZAiBModule.getPhotoBM();
    var tempRes = res.split(";");
    return tempRes;
  }

  //////////////////////////////// Disconnect Card ////////////////////////////////
  async disconnectCardJF() {
    returnCode = await ZAiBModule.disconnectCardBM();
    return returnCode;
  }

  //////////////////////////////////// Deselect Reader ////////////////////////////////////
  async deselectReaderJF() {
    var returnCode = await ZAiBModule.deselectReaderBM();
    return returnCode;
  }

  //////////////////////////////// Update License ////////////////////////////////
  async updateLicenseFileJF() {
    var returnCode = await ZAiBModule.updateLicenseFileBM();
    return returnCode;
  }

  //////////////////////////////// Get Card Status ////////////////////////////////
  async getCardStatusJF() {
      returnCode = await ZAiBModule.getCardStatusBM();
      return returnCode;
  }

  //////////////////////////////// Get RID ////////////////////////////////
  async getReaderIDJF() {

      var res = await ZAiBModule.getReaderIDBM();
      var tempRes = res.split(";");
      return tempRes;
  }

  //////////////////////////////// Get Software Info ////////////////////////////////
  async getSoftwareInfoJF(){
    var resSoftwareInfo = await ZAiBModule.getSoftwareInfoBM();
    this.setState({
      SoftwareInfo: resSoftwareInfo,
      LicenseInfo: "",
    });
    return true;
  }

  //////////////////////////////// Get License Info ////////////////////////////////
  async getLicenseInfoJF( ){
    var resLicenseInfo = await ZAiBModule.getLicenseInfoBM();
    this.setState({
      LicenseInfo: resLicenseInfo,
      ButtonView: ButtonView,
    });
    return true;
  }

  //////////////////////////////////// Close Lib ////////////////////////////////////
  async closeLibJF() {
    returnCode = ZAiBModule.closeLibBM();
    return returnCode;
  }

  //////////////////////////////////// Exception ////////////////////////////////////
  checkException(returnCode) {

    if (returnCode == NA_INTERNAL_ERROR) {
      return "-1 Internal error.";

    } else if (returnCode == NA_INVALID_LICENSE) {
      return  "-2 This reader is not licensed.";

    } else if (returnCode == NA_READER_NOT_FOUND) {
      return "-3 Reader not found.";

    } else if (returnCode == NA_CONNECTION_ERROR) {
      return "-4 Card connection error.";

    } else if (returnCode == NA_GET_PHOTO_ERROR) {
      return "-5 Get photo error.";

    } else if (returnCode == NA_GET_TEXT_ERROR) {
      return "-6 Get text error.";

    } else if (returnCode == NA_INVALID_CARD) {
      return "-7 Invalid card.";

    } else if (returnCode == NA_UNKNOWN_CARD_VERSION) {
      return "-8 Unknown card version.";

    } else if (returnCode == NA_DISCONNECTION_ERROR) {
      return "-9 Disconnection error.";

    } else if (returnCode == NA_INIT_ERROR) {
      return "-10 Init error.";

    } else if (returnCode == NA_READER_NOT_SUPPORTED) {
      return "-11 Reader not supported.";

    } else if (returnCode == NA_LICENSE_FILE_ERROR) {
      return "-12 License file error.";

    } else if (returnCode == NA_PARAMETERS_ERROR) {
      return "-13 Parameter error.";

    } else if (returnCode == NA_INTERNET_ERROR) {
      return "-15 Internet error.";
    } else if (returnCode == NA_CARD_NOT_FOUND) {
      return "-16 Card not found.";

    } else if (returnCode == NA_BLUETOOTH_DISABLED) {
      return "-17 Bluetooth is disabled.";

    } else if (returnCode == NA_LICENSE_UPDATE_ERROR) {
      return "-18 License update error.";

    } else if (returnCode == NA_STORAGE_PERMISSION_ERROR) {
      return "-31 Storage permission error.";

    } else if (returnCode == NA_LOCATION_PERMISSION_ERROR) {
      return "-32 Location permission error.";

    }else if (returnCode == NA_BLUETOOTH_PERMISSION_ERROR) {
      return "-33 Bluetooth permission error.";

    } else if (returnCode == NA_LOCATION_SERVICE_ERROR) {
      return "-41 Location service error.";

    }else{
      return returnCode.toString();
    }


  }

  ///////////////////////////////// Exit App /////////////////////////////////
  async exitApp() {

    // ================= Deselect Reader ================= //
    await this.deselectReaderJF();

    // ================= Close Lib ================= //
    await this.closeLibJF();

    RNExitApp.exitApp();

  }

  EnableButton() {
    ButtonView = [];

    ButtonView.push(
      <View key="Button">
        <Button
          title="Find Reader"
          onPress={() => this.buttonFindReader()}
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginBottom: 10,
            marginTop: 10,
          }}
        />
        <Button
          title="Read"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          onPress={() => this.buttonRead()}
        />
        <Button
          title="Card Status"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginTop: 10,
          }}
          onPress={() => this.buttonGetCardStatus()}
        />
        <Button
          title="Update License"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginTop: 10,
          }}
          onPress={() => this.buttonUpdateLicensefile()}
        />
        <Button
          title="Exit"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginTop: 10,
          }}
          onPress={() => this.exitApp()}
        />
      </View>
    );
    this.setState({
      ButtonView: ButtonView,
    });

  }

  DisableButton() {
    ButtonView = [];
    ButtonView.push(
      <View key="Button">
        <Button
          title="Find Reader"
          onPress={() => this.buttonFindReader()}
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginBottom: 10,
            marginTop: 10,
          }}
          disabled
        />
        <Button
          title="Read"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          onPress={() => this.buttonRead()}
          disabled
        />
        <Button
          title="Card Status"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginTop: 10,
          }}
          onPress={() => this.buttonGetCardStatus()}
          disabled
        />
        <Button
          title="Update License"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginTop: 10,
          }}
          onPress={() => this.buttonUpdateLicensefile()}
          disabled
        />
        <Button
          title="Exit"
          buttonStyle={{
            backgroundColor: "#707070",
          }}
          containerStyle={{
            marginTop: 10,
          }}
          onPress={() => this.exitApp()}
          
        />
      </View>
    );
    this.setState({
      ButtonView: ButtonView,
    });
  }

  render() {
    return (
      <ThemeProvider theme={theme}>
        <View>
          <Text
            style={{
              backgroundColor: "#61DBFB",
              color: "#fff",
              fontSize: 20,
              paddingLeft: 30,
              paddingRight: 30,
              paddingTop: 22,
              paddingBottom: 15,
            }}
          >
            {this.state.AppName}
          </Text>
        </View>

        <View key="Sofware_Info">
          <Text
            style={{
              backgroundColor: "#424242",
              color: "#fff",
              fontSize: 12,
              paddingLeft: 20,
              paddingRight: 20,
              paddingTop: 8,
              paddingBottom: 5,
            }}
          >
            Software Info: {this.state.SoftwareInfo}
          </Text>
        </View>


        <View key="License_Info">
          <Text
            style={{
              backgroundColor: "#424242",
              color: "#fff",
              fontSize: 12,
              paddingLeft: 20,
              paddingRight: 20,
              paddingTop: 0,
              paddingBottom: 8,
            }}
          >
           License Info: {this.state.LicenseInfo}
          </Text>
        </View>
        
        

        <View style={styles.container}>
          <View key="Reader">
            <Text style={{ fontSize: 15 }}>{this.state.readerName}</Text>
          </View>

          {this.state.ButtonView}

          <View style={{ flexDirection: "row", flex: 1 }}>
            <ScrollView
              style={{ marginTop: 10, marginBottom: 10 }}
              ref={(ref) => (scrollView = ref)}
              onContentSizeChange={() =>
                scrollView.scrollToEnd({ animated: true })
              }
            >
             
              <View key="TexCallback">
                <Text style={{ fontSize: 15, marginTop: 20 }}>{this.state.text_result}</Text>
              </View>

            </ScrollView>
            <View style={{ flexDirection: "column" }}>
              <View style={{ marginTop: 20 }}>{this.state.ImageView}</View>
            </View>
          </View>
        </View>
      </ThemeProvider>
    );
  }
}

const theme = {
  Button: {
    raised: true,
  },
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingLeft: 20,
    paddingRight: 20,
    paddingTop: 5,
    backgroundColor: "#FFFBD4",
  },
  preloader: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: "center",
    justifyContent: "center",
  },
});

export default FirstScreen;
