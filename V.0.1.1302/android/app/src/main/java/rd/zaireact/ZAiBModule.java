package rd.zaireact;

// ZAiBModule
// Copyright R&D Computer System Co., Ltd.

import android.Manifest;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Environment;
import android.os.Looper;
import android.os.Message;


import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import com.facebook.react.bridge.ReactApplicationContext;

import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
//import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import java.util.ArrayList;

import java.util.Base64;

import rd.nalib.ExceptionNA;
import rd.nalib.ZA;
import rd.nalib.ResponseListener;

class ZAiBModule extends ReactContextBaseJavaModule {

    private static final int NA_NO_ATEXT = 0x0;
    private static final int NA_ATEXT = 0x1;

    public ZA ZALibs;
    private int iRes = -999;
    private ArrayList<String> aRes = null;
    private String sRes = "";
    private byte[] byteRes = null;
    private boolean bReturnResponseFinish = false;
    private int sleepTime = 10; // = 10 ms
    private int pms;
    private String Parameter_OpenLib;
    private String str_result;
    private int listOption;
    private String readerSelect;
    public Promise tempcallBack;
    private String aKey;


    ResponseListener responseListener = new ResponseListener() {

        @Override
        public void onOpenLibNA(int i) {

            iRes = i;
            bReturnResponseFinish = true;
        }

        @Override
        public void onGetReaderListNA(ArrayList<String> arrayList, int i) {
            iRes = i;
            aRes = arrayList;
            bReturnResponseFinish = true;
        }

        @Override
        public void onSelectReaderNA(int i) {
            iRes = i;
            bReturnResponseFinish = true;
        }

        @Override
        public void onGetNIDNumberNA(String s, int i) {
            iRes = i;
            sRes = s;
            bReturnResponseFinish = true;
        }

        @Override
        public void onGetNIDTextNA(String s, int i) {

            iRes = i;
            sRes = s;
            bReturnResponseFinish = true;

        }

        @Override
        public void onGetSTextZA(String s, int i) {
            iRes = i;
            sRes = s;
            bReturnResponseFinish = true;
        }

        @Override
        public void onGetNIDPhotoNA(byte[] bytes, int i) {
            iRes = i;
            byteRes = bytes;
            bReturnResponseFinish = true;
        }

        @Override
        public void onUpdateLicenseFileNA(int i) {
            iRes = i;
            bReturnResponseFinish = true;
        }
    };


    @NonNull
    @Override
    public String getName() {
        return "ZAiBModule";
    }

    ZAiBModule(ReactApplicationContext context) {
        super(context);

    }

    @Override
    public void initialize() {
        super.initialize();
        while(getCurrentActivity() == null);

        ZALibs = new ZA(getCurrentActivity());
    }

    @ReactMethod
    public void getFilesDirBM(Promise callBack) {

        Promise tempcallBack = callBack;

        String res = String.valueOf(getCurrentActivity().getFilesDir());
        tempcallBack.resolve(res);

    }

    @ReactMethod
    public void writeLicFileBM(final String LicFile, Promise callBack) {

        Promise tempcallBack = callBack;

        int res = writeLicFile(LicFile);
        tempcallBack.resolve(res);

    }

    @ReactMethod
    public void setListenerBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Set Listener ================= */
        ZALibs.setListenerNA(responseListener);
        tempcallBack.resolve(ExceptionNA.NA_SUCCESS);

    }

    @ReactMethod
    public void setPermissionsBM(final int pms, Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Set Permission ================= */
        int res = ZALibs.setPermissionsNA(pms);
        tempcallBack.resolve(res);
    }

    @ReactMethod
    public void openLibBM(final String Parameter_OpenLib, Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Open Lib ================= */
        bReturnResponseFinish = false;
        clearReturnResponse();
        ZALibs.openLibNA(Parameter_OpenLib);
        waitResponse();
        tempcallBack.resolve(iRes);

    }

    @ReactMethod
    public void getReaderListBM(final int listOption, Promise callBack) {

        this.tempcallBack = callBack;
        this.listOption = listOption;
        /* ================= Get Reader List ================= */
        clearReturnResponse();
        bReturnResponseFinish = false;
        ZALibs.getReaderListNA(listOption);
        waitResponse();
        str_result = iRes + ";";
        if (iRes > 0) {
           str_result = iRes + ";" + aRes.get(0);
        }
        tempcallBack.resolve(str_result);
    }

    @ReactMethod
    public void selectReaderBM(final String readerSelect, Promise callBack) {

        this.tempcallBack = callBack;
        this.readerSelect = readerSelect;
        /* ================= Select Reader ================= */
        clearReturnResponse();
        bReturnResponseFinish = false;
        ZALibs.selectReaderNA(readerSelect);
        waitResponse();
        tempcallBack.resolve(iRes);
    }

    @ReactMethod
    public void getReaderInfoBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get Reader Info ================= */
        String[] data = new String[1];
        ZALibs.getReaderInfoNA(data);
        if (data[0] != null) {
            str_result = ExceptionNA.NA_SUCCESS + ";" + data[0];
        } else {
            str_result = ExceptionNA.NA_READER_NOT_FOUND + ";";
        }
        tempcallBack.resolve(str_result);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @ReactMethod
    public void getReaderIDBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get Reader ID ================= */
        final byte[] Rid = new byte[256];
        int result = ZALibs.getRidNA(Rid);
        String encoded = Base64.getEncoder().encodeToString(Rid);
        if (result > 0) {
            str_result = result + ";" + encoded;
        } else {
            str_result = result + ";";
        }
        tempcallBack.resolve(str_result);
    }

    @ReactMethod
    public void connectCardBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Connect Card ================= */
        int res = ZALibs.connectCardNA();
        tempcallBack.resolve(res);
    }

    @ReactMethod
    public void disconnectCardBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Disconnect Card ================= */
        int res = ZALibs.disconnectCardNA();
        tempcallBack.resolve(res);
    }

    @ReactMethod
    public void getTextBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get NID Text ================= */
        bReturnResponseFinish = false;
        clearReturnResponse();
        int getTextOption = NA_NO_ATEXT;
        //int getTextOption = NA_ATEXT;
        ZALibs.getNIDTextNA(getTextOption);
        waitResponse();
        str_result = iRes + ";" + sRes;
        tempcallBack.resolve(str_result);
    }

    @ReactMethod
    public void getSTextBM(final String aKey, Promise callBack) {

        this.tempcallBack = callBack;
        this.aKey = aKey;
        /*================= Get SText =================*/
        bReturnResponseFinish = false;
        clearReturnResponse();
        ZALibs.getSTextZA(aKey);
        waitResponse();
        str_result = iRes + ";" + sRes;
        tempcallBack.resolve(str_result);
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @ReactMethod
    public void getPhotoBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get NID Photo ================= */
        bReturnResponseFinish = false;
        clearReturnResponse();
        ZALibs.getNIDPhotoNA();
        waitResponse();

        str_result = iRes + ";";
        if (iRes == ExceptionNA.NA_SUCCESS) {
            String encoded = Base64.getEncoder().encodeToString(byteRes);
            str_result = iRes + ";" + encoded;

        }
        tempcallBack.resolve(str_result);
    }

    @ReactMethod
    public void getNIDNumberBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get NID Text ================= */
        bReturnResponseFinish = false;
        clearReturnResponse();
        ZALibs.getNIDNumberNA();
        waitResponse();

        str_result = iRes + ";" + sRes;
        tempcallBack.resolve(str_result);
    }

    @ReactMethod
    public void updateLicenseFileBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Update License File ================= */
        bReturnResponseFinish = false;
        clearReturnResponse();
        ZALibs.updateLicenseFileNA();
        waitResponse();
        tempcallBack.resolve(iRes);
    }

    @ReactMethod
    public void getLicenseInfoBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get License Info ================= */
        String[] data = new String[1];
        ZALibs.getLicenseInfoNA(data);
        if (data[0] != null) {
            tempcallBack.resolve(data[0]);
        }else{
            tempcallBack.resolve("-1");
        }
    }

    @ReactMethod
    public void getSoftwareInfoBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get Software Info ================= */
        String[] data = new String[1];
        ZALibs.getSoftwareInfoNA(data);

        if (data[0] != null) {
            tempcallBack.resolve(data[0]);
        }else{
            tempcallBack.resolve("-1");
        }
    }

    @ReactMethod
    public void getCardStatusBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Get Card Status ================= */
        int Result = ZALibs.getCardStatusNA();
        tempcallBack.resolve(Result);
    }

    @ReactMethod
    public void deselectReaderBM(Promise callBack) {

        this.tempcallBack = callBack;
        /* ================= Deselect Reader ================= */
        int Result = ZALibs.deselectReaderNA();
        tempcallBack.resolve(Result);
    }

    @ReactMethod
    public void closeLibBM(Promise callBack) {

        this.tempcallBack = callBack;
        /*================= Close Lib =================*/
        int Result = ZALibs.closeLibNA();
        tempcallBack.resolve(Result);
    }

    public int writeLicFile(String Path) {

        AssetManager assetManager = getCurrentActivity().getAssets();
        try {
            InputStream is = assetManager.open("rdnidlib.dls");
            File out = new File(Path);
            if (out.exists()) { //check already has License File
                return 1;
            }
            String writeLicPath = out.getParent();
            File parent = new File(writeLicPath);
            parent.mkdirs();
            byte[] buffer = new byte[1024];
            FileOutputStream fos = new FileOutputStream(out);
            int read;
            while ((read = is.read(buffer, 0, 1024)) >= 0) {
                fos.write(buffer, 0, read);
            }
            fos.flush();
            fos.close();
            is.close();
            return 0;

        } catch (IOException e) {
            e.printStackTrace();
            return -1;
        }
    }

    public void waitResponse() {
        while (!bReturnResponseFinish) {
            try {
                Thread.sleep(sleepTime);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public void clearReturnResponse() {
        iRes = -999;
        sRes = "";
        aRes = null;
        byteRes = null;
    }

}
