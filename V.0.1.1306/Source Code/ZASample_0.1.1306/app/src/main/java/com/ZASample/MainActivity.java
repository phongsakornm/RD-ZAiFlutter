package com.ZASample;

// ZASample

import static android.content.pm.PackageManager.PERMISSION_GRANTED;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import org.ksoap2.SoapEnvelope;
import org.ksoap2.SoapFault;
import org.ksoap2.serialization.SoapObject;
import org.ksoap2.serialization.SoapSerializationEnvelope;
import org.ksoap2.transport.HttpResponseException;
import org.ksoap2.transport.HttpTransportSE;
import org.xmlpull.v1.XmlPullParserException;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;

import rd.nalib.ExceptionNA;
import rd.nalib.ResponseListener;
import rd.nalib.ZA;

public class MainActivity extends AppCompatActivity {

    public static final int MY_STORAGE_PERMISSION = 0x1;
    public static final int MY_LOCATION_PERMISSION = 0x2;
    public static final int REQUEST_ALL_FILE_PERMISSION = 0x3;
    public static final int REQUEST_STORAGE_PERMISSION = 0x4;
    static String CHECKCARDBYLASER = "CheckCardByLaser";
    static String CHECKCARDBYCID = "CheckCardByCID";
    private final int sleepTime = 10;     // = 10 ms
    private final int NA_POPUP = 0x80;
    private final int NA_FIRST = 0x40;
    private final int NA_RESERVE2 = 0x20;
    private final int NA_SCAN = 0x10;
    private final int NA_BLE1 = 0x08;
    private final int NA_BLE0 = 0x04;
    private final int NA_BT = 0x02;
    private final int NA_USB = 0x01;
    private final int NA_NO_ATEXT = 0x00;
    private final int NA_ATEXT = 0x01;
    private final String mNIDReader = "/" + "ZASample";
    private final Handler handler = new Handler();
    private String ZAVersion;
    private byte[] byteRes = null;
    private boolean bReturnResponseFinish = false;
    private ZA ZALibs;
    private Button bt_SelectReader, bt_Read, /*bt_CheckCardbyLaser, bt_CheckCardbyCID,*/
            bt_UpdateLicense, bt_Exit;
    private TextView tv_Reader, tv_Result, tv_LicenseInfo, tv_SoftwareInfo, tv_PID, tv_FName, tv_LName, tv_BD, tv_LID, tv_CID, /*tv_PID2,*/
            tv_BP1;
    private ImageView iv_Photo;
    private MyHandler mHandler;
    private int iRes = -999;
    private ArrayList<String> aRes = null;
    private String sRes = "";
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
        public void onSelectReaderNA(final int i) {
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
        public void onGetNIDTextNA(final String s, int i) {
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
    private boolean flagSetting = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        try {
            ZAVersion = getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        ActionBar actionBar = getSupportActionBar();
        actionBar.setTitle("ZASample " + ZAVersion);
        HandlerThread myThread = new HandlerThread("Worker Thread");
        myThread.start();
        Looper mLooper = myThread.getLooper();
        mHandler = new MyHandler(mLooper);
        tv_Reader = findViewById(R.id.tv_Reader);
        tv_SoftwareInfo = findViewById(R.id.tv_SoftwareInfo);
        tv_LicenseInfo = findViewById(R.id.tv_LicenseInfo);
        tv_Reader = findViewById(R.id.tv_Reader);

        tv_PID = findViewById(R.id.tv_PID);
        tv_FName = findViewById(R.id.tv_FName);
        tv_LName = findViewById(R.id.tv_LName);
        tv_BD = findViewById(R.id.tv_BD);
        tv_LID = findViewById(R.id.tv_LID);
        tv_CID = findViewById(R.id.tv_CID);
        //tv_PID2 = findViewById(R.id.tv_PID2);
        tv_BP1 = findViewById(R.id.tv_bp1);
        iv_Photo = findViewById(R.id.iv_Photo);

        /*bt_CheckCardbyLaser = findViewById(R.id.bt_CheckCardbyLaser);
        bt_CheckCardbyCID = findViewById(R.id.bt_CheckCardbyCID);

        bt_CheckCardbyLaser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tv_Result.setText("");
                setEnableButton(false, false, false, false, false, false);
                CheckCard checkCardbyLaser = new CheckCard(CHECKCARDBYLASER);
                checkCardbyLaser.execute();
            }
        });

        bt_CheckCardbyCID.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tv_Result.setText("");
                setEnableButton(false, false, false, false, false, false);
                CheckCard checkCardbyCID = new CheckCard(CHECKCARDBYCID);
                checkCardbyCID.execute();
            }
        });*/

        bt_SelectReader = findViewById(R.id.bt_SelectReader);
        bt_SelectReader.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tv_Result.setText("");
                tv_Result.setClickable(false);
                iv_Photo.setImageResource(R.mipmap.ic_launcher);
                Message msg = mHandler.obtainMessage();
                msg.obj = "findreader";
                mHandler.sendMessage(msg);
            }
        });
        bt_Read = findViewById(R.id.bt_Read);
        bt_Read.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                tv_Result.setText("");
                tv_Result.setClickable(false);
                iv_Photo.setImageResource(R.mipmap.ic_launcher);
                Message msg = mHandler.obtainMessage();
                msg.obj = "read";
                mHandler.sendMessage(msg);
            }
        });
        bt_UpdateLicense = findViewById(R.id.bt_Update);
        bt_UpdateLicense.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                tv_Result.setText("");
                tv_Result.setClickable(false);
                iv_Photo.setImageResource(R.mipmap.ic_launcher);
                Message msg = mHandler.obtainMessage();
                msg.obj = "updatelicense";
                mHandler.sendMessage(msg);
            }
        });
        bt_Exit = findViewById(R.id.bt_Exit);
        bt_Exit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                /*================= Deselect Reader =================*/
                ZALibs.deselectReaderNA();

                /*================= Close Lib =================*/
                ZALibs.closeLibNA();
                System.exit(0);
            }
        });
        tv_Result = findViewById(R.id.tv_Result);


        ProgressDialog progressDialog = new ProgressDialog(this);
        progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        progressDialog.setMessage("Scan bluetooth");

        ZALibs = new ZA(this);

        /*================= get Software Info =================*/
        clearReturnResponse();
        String[] data = new String[1];
        ZALibs.getSoftwareInfoNA(data);
        if (data[0] != null) {
            tv_SoftwareInfo.setText("Software Info: " + data[0]);
        }

        ZALibs.setListenerNA(responseListener);

        /************** Location Permission for Bluetooth reader *************/
        /*           Can remove this block if use USB reader only            */

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT}, MY_LOCATION_PERMISSION);
        } else {
            if (ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) != PERMISSION_GRANTED) {
                AlertDialog dialog = new AlertDialog.Builder(MainActivity.this).create();
                dialog.setTitle("Permission");
                dialog.setMessage("Please allow Location permission if use Bluetooth reader.");
                dialog.setCancelable(false);
                dialog.setCanceledOnTouchOutside(false);
                dialog.setButton(androidx.appcompat.app.AlertDialog.BUTTON_POSITIVE, "Close", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, MY_LOCATION_PERMISSION);
                        dialog.dismiss();
                    }
                });
                dialog.show();
                dialog.getButton(AlertDialog.BUTTON_POSITIVE).setAllCaps(false);

            } else {
                ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, MY_LOCATION_PERMISSION);
            }
            init();
        }

        /*********************************************************************/
    }

    public void init() {
        /*** set USB reader in-app permission ***/
        /***
         pms: 0 = Disable USB reader in-app permission (default).
         pms: 1 = Enable USB reader in-app permission.
         pms: -1 = Get current permissions state.
         ***/

        int pms = 1;
        ZALibs.setPermissionsNA(pms);

        clearReturnResponse();

        String mNIDReader = "/" + "ZASample";
        String rootFolder = getFilesDir() + mNIDReader;
        String LICFileName = "/" + "rdnidlib.dls";
        writeFile(rootFolder + LICFileName, "rdnidlib.dls");                         // Write file Licence

        /*===================== Open Libs =====================*/
        ZALibs.openLibNA(rootFolder + LICFileName);

        if (iRes != 0) {
            tv_Result.setClickable(false);
            tv_Result.setText("Open Lib failed; Please restart app");
            bt_SelectReader.setEnabled(false);
            bt_Read.setEnabled(false);
            bt_UpdateLicense.setEnabled(false);
            bt_Exit.setEnabled(true);
            return;
        }

        /*================= get License Info =================*/
        clearReturnResponse();
        String[] data = new String[1];
        ZALibs.getLicenseInfoNA(data);
        if (data[0] != null) {
            tv_LicenseInfo.setText("License Info: " + data[0]);
        }
        bt_SelectReader.setEnabled(true);
        bt_Read.setEnabled(true);
        bt_UpdateLicense.setEnabled(true);
        bt_Exit.setEnabled(true);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        int i = 0;
        for (String permission : permissions) {
            if (permission.compareTo(Manifest.permission.BLUETOOTH_SCAN) == 0 || permission.compareTo(Manifest.permission.BLUETOOTH_CONNECT) == 0) {
                if (grantResults[i] == PERMISSION_GRANTED) {
                    init();
                    return;
                }
            }
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        /*================= Deselect Reader =================*/
        ZALibs.deselectReaderNA();

        /*================= Close Lib =================*/
        ZALibs.closeLibNA();
        System.exit(0);
    }

    public void setText(TextView tv, final String message) {
        tv_Result.setClickable(false);
        final TextView textView = tv;
        handler.post(() -> textView.setText(message));
    }

    public void clearReturnResponse() {
        iRes = -999;
        sRes = "";
        aRes = null;
        byteRes = null;
    }

    public void setEnableButton(final boolean SelectReader, final boolean Read, final boolean CheckCardbyCID, final boolean CheckCardbyLaser, final boolean Update, final boolean Exit) {
        handler.post(new Runnable() {
            public void run() {
                bt_SelectReader.setEnabled(SelectReader);
                bt_Read.setEnabled(Read);
                /*bt_CheckCardbyCID.setEnabled(CheckCardbyCID);
                bt_CheckCardbyLaser.setEnabled(CheckCardbyLaser);*/
                bt_UpdateLicense.setEnabled(Update);
                bt_Exit.setEnabled(Exit);
            }
        });
    }

    public void writeFile(String Path, String Filename) {
        AssetManager assetManager = getAssets();
        try {
            InputStream is = assetManager.open(Filename);
            File out = new File(Path);
            if (out.exists())
                return;
            File parent = new File(out.getParent());
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
        } catch (IOException e) {
            e.printStackTrace();
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

    private void printException(int ex, String OldText) {

        if (OldText.compareTo("") != 0) {
            OldText += "\n\n";
        }
        switch (ex) {
            case ExceptionNA.NA_INTERNAL_ERROR:
                setText(tv_Result, OldText + "-1 Internal error.");
                break;

            case ExceptionNA.NA_INVALID_LICENSE:
                setText(tv_Result, OldText + "-2 This reader is not licensed.");
                break;

            case ExceptionNA.NA_READER_NOT_FOUND:
                setText(tv_Result, OldText + "-3 Reader not found.");
                break;

            case ExceptionNA.NA_CONNECTION_ERROR:
                setText(tv_Result, OldText + "-4 Card connection error.");
                break;

            case ExceptionNA.NA_GET_PHOTO_ERROR:
                setText(tv_Result, OldText + "-5 Get photo error.");
                break;

            case ExceptionNA.NA_GET_TEXT_ERROR:
                setText(tv_Result, OldText + "-6 Get text error.");
                break;

            case ExceptionNA.NA_INVALID_CARD:
                setText(tv_Result, OldText + "-7 Invalid card.");
                break;

            case ExceptionNA.NA_UNKNOWN_CARD_VERSION:
                setText(tv_Result, OldText + "-8 Unknown card version.");
                break;

            case ExceptionNA.NA_DISCONNECTION_ERROR:
                setText(tv_Result, OldText + "-9 Disconnection error.");
                break;

            case ExceptionNA.NA_INIT_ERROR:
                setText(tv_Result, OldText + "-10 Init error.");
                break;

            case ExceptionNA.NA_READER_NOT_SUPPORTED:
                setText(tv_Result, OldText + "-11 Reader not supported.");
                break;

            case ExceptionNA.NA_LICENSE_FILE_ERROR:
                setText(tv_Result, OldText + "-12 License file error.");
                break;

            case ExceptionNA.NA_PARAMETER_ERROR:
                setText(tv_Result, OldText + "-13 Parameter error.");
                break;

            case ExceptionNA.NA_INTERNET_ERROR:
                setText(tv_Result, OldText + "-15 Internet error.");
                break;

            case ExceptionNA.NA_CARD_NOT_FOUND:
                setText(tv_Result, OldText + "-16 Card not found.");
                break;

            case ExceptionNA.NA_BLUETOOTH_DISABLED:
                setText(tv_Result, OldText + "-17 Bluetooth is disabled.");
                break;

            case ExceptionNA.NA_LICENSE_UPDATE_ERROR:
                setText(tv_Result, OldText + "-18 License update error.");
                break;

            case ExceptionNA.NA_STORAGE_PERMISSION_ERROR:
                setText(tv_Result, OldText + ExceptionNA.NA_STORAGE_PERMISSION_ERROR + " Storage permission error: Settings >");
                tv_Result.setClickable(true);
                tv_Result.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            if (!Environment.isExternalStorageManager()) {
                                try {
                                    Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                                    intent.addCategory("android.intent.category.DEFAULT");
                                    intent.setData(Uri.parse(String.format("package:%s", getApplicationContext().getPackageName())));
                                    startActivityForResult(intent, REQUEST_ALL_FILE_PERMISSION);
                                } catch (Exception e) {
                                    Intent intent = new Intent();
                                    intent.setAction(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
                                    startActivityForResult(intent, REQUEST_ALL_FILE_PERMISSION);
                                }
                            }

                            if (ContextCompat.checkSelfPermission(v.getContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE) != PERMISSION_GRANTED) {
                                Intent intent = new Intent();
                                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                                intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                                Uri uri = Uri.fromParts("package", getPackageName(), null);
                                intent.setData(uri);
                                if (!flagSetting) {
                                    flagSetting = true;
                                    startActivityForResult(intent, REQUEST_STORAGE_PERMISSION);
                                }
                            }
                        } else {
                            Intent intent = new Intent();
                            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                            intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                            Uri uri = Uri.fromParts("package", getPackageName(), null);
                            intent.setData(uri);
                            if (!flagSetting) {
                                flagSetting = true;
                                startActivityForResult(intent, REQUEST_STORAGE_PERMISSION);
                            }
                        }
                    }
                });
                break;

            case ExceptionNA.NA_LOCATION_PERMISSION_ERROR:
                setText(tv_Result, OldText + ExceptionNA.NA_LOCATION_PERMISSION_ERROR + " Location permission error: Settings >");
                tv_Result.setClickable(true);
                tv_Result.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent();
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                        Uri uri = Uri.fromParts("package", getPackageName(), null);
                        intent.setData(uri);
                        if (!flagSetting) {
                            flagSetting = true;
                            startActivity(intent);
                        }
                    }
                });
                break;

            case ExceptionNA.NA_BLUETOOTH_PERMISSION_ERROR:
                setText(tv_Result, OldText + "-33 Bluetooth permission error.");
                break;

            case ExceptionNA.NA_LOCATION_SERVICE_ERROR:
                setText(tv_Result, OldText + "-41 Location service error.");
                break;

            default:
                break;

        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (flagSetting) {
            Intent intent = new Intent(this, MainActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
            flagSetting = false;
        }
    }


    class MyHandler extends Handler {
        MyHandler(Looper myLooper) {
            super(myLooper);
        }

        public void handleMessage(Message msg) {
            String message = (String) msg.obj;
            switch (message) {

                /*================= When Click [Find Reader Button]   =================*/
                case "findreader": {
                    int listOption = NA_POPUP + NA_SCAN + NA_BLE1 + NA_BLE0 + NA_BT + NA_USB;     //0x9F USB & BLE Reader
                    setEnableButton(false, false, false, false, false, false);

                    /*================= get Reader List =================*/
                    bReturnResponseFinish = false;
                    clearReturnResponse();

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        if ((listOption & NA_SCAN) != 0 && ((listOption & NA_BT) != 0 || (listOption & NA_BLE1) != 0 || (listOption & NA_BLE0) != 0)) {
                            if (ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.BLUETOOTH_SCAN) == PERMISSION_GRANTED &&
                                    ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
                                listOption = listOption;
                            } else {
                                listOption = listOption - (NA_SCAN + NA_BLE1 + NA_BLE0 + NA_BT);  //remove BT Scanning
                            }
                        }
                    } else {
                        if ((listOption & NA_SCAN) != 0 && ((listOption & NA_BT) != 0 || (listOption & NA_BLE1) != 0 || (listOption & NA_BLE0) != 0)) {
                            if (ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) == PERMISSION_GRANTED) {
                                listOption = listOption;
                            } else {
                                listOption = listOption - (NA_SCAN + NA_BLE1 + NA_BLE0 + NA_BT);  //remove BT Scanning
                            }
                        }
                    }

                    ZALibs.getReaderListNA(listOption);

                    waitResponse();

                    printException(iRes, "");

                    if (iRes == 0) {
                        setEnableButton(true, true, true, true, true, true);
                        break;
                    }

                    if (iRes < 0) {
                        setText(tv_Reader, "Reader not found.");
                        setEnableButton(true, true, true, true, true, true);
                        break;
                    }

                    String readerSelect = aRes.get(0);

                    /*================= Select Reader =================*/
                    bReturnResponseFinish = false;
                    clearReturnResponse();
                    setText(tv_Reader, "Reader Selecting...");
                    ZALibs.selectReaderNA(readerSelect);
                    waitResponse();

                    printException(iRes, "");

                    String[] data = new String[1];
                    ZALibs.getLicenseInfoNA(data);
                    if (data[0] != null) {
                        setText(tv_LicenseInfo, "License Info: " + data[0]);
                    }

                    setEnableButton(true, true, true, true, true, true);
                    if (iRes != ExceptionNA.NA_SUCCESS && iRes != ExceptionNA.NA_INVALID_LICENSE && iRes != ExceptionNA.NA_LICENSE_FILE_ERROR) {
                        setText(tv_Reader, "Reader not found.");
                        break;
                    } else if (iRes == ExceptionNA.NA_INVALID_LICENSE || iRes == ExceptionNA.NA_LICENSE_FILE_ERROR) {
                        setText(tv_Reader, "Reader: " + readerSelect);
                        break;
                    }

                    setText(tv_Reader, "Reader: " + readerSelect);

                    data = new String[1];
                    if (ZALibs.getReaderInfoNA(data) == 0) {
                        setText(tv_Result, "getReaderInfoNA: " + data[0]);
                    }

                    break;
                }


                /*================= When Click [Read Button] =================*/
                case "read": {
                    long startTime = System.currentTimeMillis();
                    setEnableButton(false, false, false, false, false, false);
                    //clear Screen
                    handler.post(new Runnable() {
                        public void run() {
                            tv_Result.setText("");
                            tv_PID.setText("");
                            tv_FName.setText("");
                            tv_LName.setText("");
                            tv_BD.setText("");
                            tv_LID.setText("");
                            tv_CID.setText("");
                            //tv_PID2.setText("");
                            tv_BP1.setText("");
                            iv_Photo.setImageResource(R.mipmap.ic_launcher);
                        }
                    });

                    /*================= Connect Card =================*/
                    int result = ZALibs.connectCardNA();
                    if (result != ExceptionNA.NA_SUCCESS) {
                        setEnableButton(true, true, true, true, true, true);
                        printException(result, "");
                        //setText(tv_Result, "Card connection error.");
                        break;
                    }

                    /*================= Get NID Text =================*/
                    bReturnResponseFinish = false;
                    clearReturnResponse();
                    int getTextOption = NA_NO_ATEXT;
                    //int getTextOption = NA_ATEXT;
                    ZALibs.getNIDTextNA(getTextOption);
                    String aKey = "";
                    waitResponse();

                    printException(iRes, "");

                    if (iRes != ExceptionNA.NA_SUCCESS) {
                        setEnableButton(true, true, true, true, true, true);
                        ZALibs.disconnectCardNA();
                        break;
                    } else {
                        final String[] sData = sRes.split("#");
                        if (sData.length == 1) {
                            handler.post(new Runnable() {
                                public void run() {
                                    tv_Result.setText(sData[0]);
                                    setEnableButton(true, true, true, true, true, true);
                                }
                            });
                            break;
                        } else {
                            aKey = sData[0].substring(2, 5) + sData[0].substring(9, 11);
                            handler.post(new Runnable() {
                                public void run() {
                                    tv_PID.setText(sData[0]);
                                    //tv_PID2.setText(sData[0]);
                                    tv_FName.setText(sData[2]);
                                    tv_LName.setText(sData[4]);
                                    tv_BD.setText(sData[18]);
                                }
                            });
                        }
                    }

                    /*================= Get SText =================*/
                    bReturnResponseFinish = false;
                    clearReturnResponse();
                    ZALibs.getSTextZA(aKey);
                    waitResponse();

                    printException(iRes, "");

                    if (iRes != ExceptionNA.NA_SUCCESS) {
                        setEnableButton(true, true, true, true, true, true);
                        ZALibs.disconnectCardNA();
                        break;
                    } else {
                        final String[] sData = sRes.split("#");
                        if (sData.length == 1) {
                            handler.post(new Runnable() {
                                public void run() {
                                    tv_Result.setText(sData[0]);
                                    setEnableButton(true, true, true, true, true, true);
                                }
                            });
                        } else {
                            handler.post(new Runnable() {
                                public void run() {
                                    tv_LID.setText(sData[0]);
                                    tv_CID.setText(sData[1]);
                                    tv_BP1.setText(sData[2]);
                                    //setEnableButton(true, true, true, true, true, true);
                                }
                            });
                        }
                    }

                    /*************************** Read photo from Thai ID card **************************/
                    /*================= Connect Card =================*/
                    /*result = ZALibs.connectCardNA();
                    if (result != ExceptionNA.NA_SUCCESS) {
                        setEnableButton(true, true, true, true, true, true);
                        printException(result, "");
                        //setText(tv_Result, "Card connection error.");
                        break;
                    }*/
                    /*================= Get NID Photo =================*/
                    bReturnResponseFinish = false;
                    clearReturnResponse();
                    ZALibs.getNIDPhotoNA();
                    waitResponse();

                    printException(iRes, "");

                    if (iRes == 0) {
                        final Bitmap bMap = BitmapFactory.decodeByteArray(byteRes, 0, byteRes.length);
                        handler.post(() -> iv_Photo.setImageBitmap(bMap));
                    }
                    /***********************************************************************************/

                    /*================= Disconnect Card =================*/
                    ZALibs.disconnectCardNA();


                    setEnableButton(true, true, true, true, true, true);

                    if (iRes >= 0) {
                        final long difference2 = System.currentTimeMillis() - startTime;
                        final BigDecimal bd2 = new BigDecimal(difference2 / 1000.0);
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                setText(tv_Result, tv_Result.getText().toString() + "Reading Time: " + bd2.setScale(2, RoundingMode.HALF_UP) + " s");
                            }
                        });
                    }
                    break;
                }

                /*================= When Click [Update License Button] =================*/
                case "updatelicense": {
                    setEnableButton(false, false, false, false, false, false);

                    /*================= Update License File =================*/
                    bReturnResponseFinish = false;
                    clearReturnResponse();
                    ZALibs.updateLicenseFileNA();
                    waitResponse();

                    /*================= Retry Update =================*/
                    if (iRes == ExceptionNA.NA_LICENSE_UPDATE_ERROR) {
                        bReturnResponseFinish = false;
                        clearReturnResponse();
                        ZALibs.updateLicenseFileNA();
                        waitResponse();
                    }

                    printException(iRes, "");

                    /*if (iRes == ExceptionNA.NA_SUCCESS) {
                        String[] data = new String[1];
                        ZALibs.getLicenseInfoNA(data);
                        if (data[0] != null) {
                            setText(tv_LicenseInfo, "License Info: " + data[0]);
                        }
                        setText(tv_Result, iRes + ": License has been successfully updated.");
                    } else if (iRes == 1) {
                        setText(tv_Result, iRes + ": The latest license has already been installed.");
                    }*/

                    if (iRes == 0 || iRes == 1 || iRes == 2 || iRes == 3) {
                        String[] data = new String[1];
                        ZALibs.getLicenseInfoNA(data);
                        if (data[0] != null) {
                            setText(tv_LicenseInfo, "License Info: " + data[0]);
                        }
                        setText(tv_Result, iRes + ": License has been successfully updated.");
                    } else if (iRes == 100 || iRes == 101 || iRes == 102 || iRes == 103) {
                        setText(tv_Result, iRes + ": The latest license has already been installed.");
                    }

                    setEnableButton(true, true, true, true, true, true);
                    break;
                }
            }
        }
    }

    @SuppressLint("StaticFieldLeak")
    private class CheckCard extends AsyncTask<Void, Void, Void> {

        String SOAP_ACTION;
        String METHOD_NAME;
        String NAMESPACE = "http://tempuri.org/";

        CheckCard(String METHOD_NAME) {
            super();
            this.METHOD_NAME = METHOD_NAME;
            this.SOAP_ACTION = "http://tempuri.org/" + METHOD_NAME;
        }

        SoapObject setRequest(String METHOD_NAME) {
            SoapObject request = new SoapObject(NAMESPACE, METHOD_NAME);
            if (METHOD_NAME.equals(CHECKCARDBYLASER)) {
                request.addProperty("PID", tv_PID.getText().toString());                      // adding method property here serially
                request.addProperty("FirstName", tv_FName.getText().toString());              // adding method property here serially
                request.addProperty("LastName", tv_LName.getText().toString());               // adding method property here serially
                request.addProperty("BirthDay", tv_BD.getText().toString());                  // adding method property here serially
                request.addProperty("Laser", tv_LID.getText().toString());                    // adding method property here serially
            } else if (METHOD_NAME.equals(CHECKCARDBYCID)) {
                request.addProperty("ChipNo", tv_CID.getText().toString());                   // adding method property here serially
                //request.addProperty("pid", tv_PID2.getText().toString());                     // adding method property here serially
                request.addProperty("bp1no", tv_BP1.getText().toString());                    // adding method property here serially
            }
            return request;
        }

        @Override
        protected Void doInBackground(Void... params) {
            String URL = "https://idcard.bora.dopa.go.th/CheckCardStatus/CheckCardService.asmx";

            //for linear parameter
            SoapObject request = setRequest(this.METHOD_NAME);
            SoapSerializationEnvelope envelope = new SoapSerializationEnvelope(SoapEnvelope.VER11);
            envelope.implicitTypes = true;
            envelope.setOutputSoapObject(request);
            envelope.dotNet = true;

            HttpTransportSE httpTransport = new HttpTransportSE(URL);
            httpTransport.debug = true;

            try {
                httpTransport.call(SOAP_ACTION, envelope);
            } catch (HttpResponseException e) {
                Log.e("HTTPLOG", e.getMessage());
                e.printStackTrace();
            } catch (IOException e) {
                Log.e("IOLOG", e.getMessage());
                e.printStackTrace();
            } catch (XmlPullParserException e) {
                Log.e("XMLLOG", e.getMessage());
                e.printStackTrace();
            } //send request

            Object result;
            try {
                result = envelope.getResponse();
                Log.i("RESPONSE", String.valueOf(result));                                     //see output in the console
                final Object finalResult = result;
                if (finalResult != null) {
                    int propertyCount = ((SoapObject) finalResult).getPropertyCount();
                    StringBuilder output = new StringBuilder();
                    for (int i = 0; i < propertyCount; i++) {
                        if (((SoapObject) finalResult).getPropertyInfo(i).getType().equals(SoapObject.class)) {
                            output.append(((SoapObject) finalResult).getPropertyInfo(i).getName());
                            int subPropertyCount = ((SoapObject) ((SoapObject) finalResult).getPropertyInfo(i).getValue()).getPropertyCount();
                            if (subPropertyCount == 0) {
                                output.append(" = {}\n");
                            } else {
                                output.append(" = {\n");
                                for (int j = 0; j < propertyCount; j++) {
                                    output.append("   ");
                                    output.append(((SoapObject) finalResult).getPropertyInfo(j).getName());
                                    output.append(" = ");
                                    output.append(((SoapObject) finalResult).getPropertyAsString(j));
                                    output.append("\n");
                                }
                                output.append(" = }\n");
                            }

                        } else {
                            output.append(((SoapObject) finalResult).getPropertyInfo(i).getName());
                            output.append(" = ");
                            output.append(((SoapObject) finalResult).getPropertyAsString(i));
                            output.append("\n");
                        }
                    }
                    final String finalOutput = output.toString();
                    handler.post(new Runnable() {
                        @Override
                        public void run() {

                            tv_Result.setText(finalOutput);
                            setEnableButton(true, true, true, true, true, true);
                        }
                    });
                } else {
                    handler.post(new Runnable() {
                        @Override
                        public void run() {
                            tv_Result.setText("Web service error.");
                            setEnableButton(true, true, true, true, true, true);
                        }
                    });
                }
            } catch (final SoapFault e) {
                Log.e("SOAPLOG", e.getMessage());
                e.printStackTrace();
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        tv_Result.setText(String.valueOf(e.getMessage()));
                        setEnableButton(true, true, true, true, true, true);
                    }
                });
            }

            return null;
        }
    }
}
