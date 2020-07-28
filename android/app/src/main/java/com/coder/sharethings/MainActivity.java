package com.coder.sharethings;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.location.LocationManager;
import android.net.Uri;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.MediaStore;
import android.provider.Settings;
import android.widget.Toast;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private  static  final String CHANNEL="Native.code/wifi";
    private  static  final String CHANNEL1="Native.code/deviceList";
    private  static  final String CHANNEL2="Native.code/SplitFiles";
    private  static  final String CHANNEL3="Native.code/GetMedia";
    private static final int REQUEST_LOCATION = 123;

    @SuppressLint("MissingPermission")
    @Override
    public void configureFlutterEngine( FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        WifiManager manager=(WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "wifiOn":
                            if (!manager.isWifiEnabled()) {
                                manager.setWifiEnabled(true);

                            } else {
                                Toast.makeText(getApplicationContext(), "Wifi on", Toast.LENGTH_LONG).show();

                            }
                            if (!manager.isWifiEnabled()) {
                                Toast.makeText(getApplicationContext(), "Wifi off", Toast.LENGTH_LONG).show();
                            }
                            break;
                        case "Hotspot":
                            HotPostManager hotPostManager = new HotPostManager(this.getApplicationContext());
                            if (hotPostManager.isApOn()) {
                                Toast.makeText(getApplicationContext(), "Hotspot is on", Toast.LENGTH_LONG).show();
                                result.success(true);
                            }
                            else {
                                Toast.makeText(getApplicationContext(), "Hotspot is off", Toast.LENGTH_LONG).show();
                                result.success(false);
                            }
                            break;
                        case "checkWifi":
                            if (manager.isWifiEnabled()) {
                                result.success(true);
                            } else {
                                result.success(false);
                            }
                            break;
                    }

                });

        deviceList(flutterEngine,manager);
        getAllPhoto(flutterEngine);

    }

    private void getAllPhoto(FlutterEngine flutterEngine) {
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL3
        ).setMethodCallHandler((methodCall, result) -> {
            if(methodCall.method.equals("Photos")){
                ArrayList<HashMap<String,String>> photosList=new ArrayList<>();
                ContentResolver cr=getActivity().getContentResolver();
                Uri uri= MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                Cursor cursor=cr.query(uri, new String[]{
                                MediaStore.Images.Media._ID,
                                MediaStore.Images.Media.DATE_ADDED,
                                MediaStore.Images.Media.DATA,
                                MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                                MediaStore.Images.Media.BUCKET_ID,
                                MediaStore.Images.Media.ORIENTATION,
                                MediaStore.Images.Media.MIME_TYPE
                        }
                        ,null
                        ,null, MediaStore.Images.Media.DATE_ADDED + " DESC");
                int count=0;
                if(cursor!=null){
                    count=cursor.getCount();
                    if(count>0){
                        while(cursor.moveToNext()){
                            HashMap hashMap=new HashMap<>();
                            String imagePath=cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
                            String id=cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media._ID));
                            hashMap.put("Path", imagePath);
                            hashMap.put("id", id);
                            photosList.add(hashMap);
                        }
                    }
                    cursor.close();
                    result.success(photosList);
                }


            }
            else if(methodCall.method.equals("Videos")){
                ArrayList<HashMap<String,String>> videoList=new ArrayList<>();
                ContentResolver cr=getActivity().getContentResolver();
                Uri uri=MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                Cursor cursor=cr.query(uri, new String[]{
                                MediaStore.Video.Media._ID,
                                MediaStore.Video.Media.DATE_ADDED,
                                MediaStore.Video.Media.DATA,
                                MediaStore.Video.Media.MIME_TYPE
                        }
                        ,null
                        ,null, MediaStore.Video.Media.DATE_ADDED + " DESC");
                int count=0;
                if(cursor!=null){
                    count=cursor.getCount();
                    if(count>0){
                        while(cursor.moveToNext()){
                            HashMap hashMap=new HashMap<>();
                            String videoPath=cursor.getString(cursor.getColumnIndex(MediaStore.Video.Media.DATA));
                            String id=cursor.getString(cursor.getColumnIndex(MediaStore.Video.Media._ID));
                            hashMap.put("Path", videoPath);
                            hashMap.put("id", id);
                            videoList.add(hashMap);
                        }
                    }
                    cursor.close();
                    result.success(videoList);

                }

            }
            else if(methodCall.method.equals("getAllApps")){
                PackageManager packageManager=getPackageManager();
                List<ApplicationInfo> apps=packageManager.getInstalledApplications(PackageManager.GET_SHARED_LIBRARY_FILES);
                ArrayList<HashMap> listApps=new ArrayList<>();
                for(ApplicationInfo applicationInfo:apps){
                    if((applicationInfo.flags & ApplicationInfo.FLAG_SYSTEM)==0){
                        HashMap appsInfo=new HashMap();
                        appsInfo.put("Path",applicationInfo.sourceDir);
                        Drawable drawable= applicationInfo.loadIcon(getPackageManager());
                        Bitmap bitmap=Bitmap.createBitmap(
                                drawable.getIntrinsicWidth(),
                                drawable.getIntrinsicHeight(),
                                Bitmap.Config.ARGB_8888
                        );
                        final Canvas canvas=new Canvas(bitmap);
                        drawable.setBounds(0,0,canvas.getWidth(),canvas.getHeight());
                        drawable.draw(canvas);
                        ByteArrayOutputStream byteArrayOutputStream=new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.JPEG,100,byteArrayOutputStream);
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO) {
                            appsInfo.put("logo", byteArrayOutputStream.toByteArray());
                        }
                        appsInfo.put("name", applicationInfo.loadLabel(getPackageManager()));
                        appsInfo.put("PackageName", applicationInfo.packageName);
//                        Toast.makeText(getApplicationContext(),applicationInfo.loadLabel(getPackageManager()).toString(),Toast.LENGTH_LONG).show();
                        listApps.add(appsInfo);
                    }


                }
                result.success(listApps);
            }

        });
    }


    @SuppressLint("MissingPermission")
    private void deviceList(FlutterEngine flutterEngine, WifiManager manager) {
        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL1
        ).setMethodCallHandler(((methodCall, result) -> {
            switch (methodCall.method) {
                case "deviceList":
                    List<ScanResult> scanWifi = manager.getScanResults();
                    List<HashMap> listWifi = new ArrayList<>();
                    for (int i = 0; i < scanWifi.size(); i++) {
                        HashMap<String, Object> maps = new HashMap<>();
                        maps.put("ssid", scanWifi.get(i).SSID);
                        maps.put("level", scanWifi.get(i).level);
//                        maps.put("netId",scanWifi.get(i).)
                        listWifi.add(maps);
                    }

                    result.success(listWifi);

                    break;
                case "ConnectedDeviceInfo":
                    if(manager.getConnectionInfo().getIpAddress()!=0){
                        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.M) {
                            if (!manager.getConnectionInfo().getBSSID().equals("00:00:00:00:00:00")) {
                                result.success(manager.getConnectionInfo().getSSID());
                            } else {
                                result.success("<unknown ssid>");
                            }
                        } else {
                            result.success(manager.getConnectionInfo().getSSID());
                        }
                    }
                    else {
                        result.success("<unknown ssid>");

                    }
                    break;
                case "locationPermission":
                    LocationManager locationManager;
                    locationManager= (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        if(getApplicationContext().checkSelfPermission( Manifest.permission.ACCESS_COARSE_LOCATION)!= PackageManager.PERMISSION_GRANTED){
                            Toast.makeText(getApplicationContext(),"Allow Location Permission",Toast.LENGTH_LONG).show();
                            startActivity(new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                    Uri.fromParts("package",getPackageName(),null)));
                        }
                        else if(!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)){
                            result.success(true);
                        }
                        else{
                            result.success(false);
                        }
                    }
                    break;
                case "TurnOnLocation":
                    LocationManager locationManager1;
                    locationManager1= (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);
                    if(!locationManager1.isProviderEnabled(LocationManager.GPS_PROVIDER)){
                        startActivity(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS));
                    }
                    break;
                case "ConnectToDevice":
                    WifiConfiguration wifiConfiguration=new WifiConfiguration();
                    wifiConfiguration.SSID=String.format("\"%s\"",methodCall.argument("ssid").toString());
                    wifiConfiguration.preSharedKey=String.format("\"%s\"",methodCall.argument("password").toString());
                    WifiManager wifiManager=(WifiManager)getApplicationContext().getSystemService(WIFI_SERVICE);
                    int netId=wifiManager.addNetwork(wifiConfiguration);
                    wifiManager.disconnect();
                    boolean isValid= wifiManager.enableNetwork(netId,true);

//                    if(isValid){
//                        wifiManager.disableNetwork(netId);
//                    }

                    boolean isConnected= wifiManager.reconnect();
                    if(isConnected){
//                       Toast.makeText(getApplicationContext(),wifiManager.saveConfiguration().+"",Toast.LENGTH_LONG).show();
                    }
                    result.success(netId);
                    break;
                case "CheckConnectivityOfWifiOnScanQrCodePress":
                    if(manager.getConnectionInfo().getIpAddress()==0){
                        Toast.makeText(getApplicationContext(),"Please Connect to Hotspot",Toast.LENGTH_LONG).show();
                    }
                    break;
            }

        }));
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if(requestCode == REQUEST_LOCATION) {
            if(grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                System.out.println("Location permissions granted, starting location");

            }

        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

}
