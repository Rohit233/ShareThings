package com.coder.sharethings;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Handler;
import android.widget.Toast;

import androidx.annotation.RequiresApi;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Formatter;
import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;

public class HotPostManager {

    public static final String TAG = "ApManager";
    WifiManager mWifiManager;
    private Context context;
    private WifiManager.LocalOnlyHotspotReservation mReservation;
    String ssid;
    String Password;
    WifiConfiguration configuration;
    public WifiManager.LocalOnlyHotspotReservation getmReservation() {
        return mReservation;
    }

    public void setmReservation(WifiManager.LocalOnlyHotspotReservation mReservation) {
        this.mReservation = mReservation;
    }

    public HotPostManager(Context context) {
        this.context = context;
    }
    //check whether wifi hotspot on or off
    public boolean isApOn() {
        try {
            Method method = mWifiManager.getClass().getDeclaredMethod("isWifiApEnabled");
            method.setAccessible(true);
            return (Boolean) method.invoke(mWifiManager);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public boolean setWifiApConfiguration(MethodChannel.Result result) {
        mWifiManager = (WifiManager) this.context.getSystemService(Context.WIFI_SERVICE);
        HashMap hashMap=new HashMap();
        try {

            if (mWifiManager.isWifiEnabled()){
                mWifiManager.setWifiEnabled(false);
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if(!isApOn()) {
                    mWifiManager.startLocalOnlyHotspot(new WifiManager.LocalOnlyHotspotCallback() {

                        @Override
                        public void onStarted(WifiManager.LocalOnlyHotspotReservation reservation) {
                            mReservation=null;
                            mReservation = reservation;
                            hashMap.put("SSID", reservation.getWifiConfiguration().SSID);
                            hashMap.put("Password", reservation.getWifiConfiguration().preSharedKey);
//                            Toast.makeText(context, hashMap.toString(), Toast.LENGTH_LONG).show();
                            result.success(hashMap);
                            super.onStarted(reservation);

                        }


                    }, new Handler());

               return true;
                }
                else{
                    if(mReservation!=null){
                        hashMap.put("SSID", mReservation.getWifiConfiguration().SSID);
                        hashMap.put("Password", mReservation.getWifiConfiguration().preSharedKey);
                        result.success(hashMap);
                    }
                    else{
                        Toast.makeText(context,"Please Disable hotspot app create hotspot automatically",Toast.LENGTH_LONG).show();
                    }
                }

            }
            else{
                WifiManager wifiManager = (WifiManager)context.getSystemService(Context.WIFI_SERVICE);
                WifiConfiguration wifiConfiguration = new WifiConfiguration();
                wifiConfiguration.SSID = Build.MANUFACTURER+""+Build.MODEL;
                wifiConfiguration.preSharedKey="123456789";
                wifiConfiguration.hiddenSSID=false;
                wifiConfiguration.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED);
                wifiConfiguration.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
                wifiConfiguration.allowedProtocols.set(WifiConfiguration.Protocol.WPA);
                wifiConfiguration.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
                try{
                   Method method= wifiManager.getClass().getDeclaredMethod("setWifiApEnabled",
                            WifiConfiguration.class,Boolean.TYPE
                            );
                    method.invoke(wifiManager,wifiConfiguration,true);
                    hashMap.put("SSID",wifiConfiguration.SSID);
                    hashMap.put("Password",wifiConfiguration.preSharedKey);
                    configuration=wifiConfiguration;
                    try {
                        for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
                            NetworkInterface intf = en.nextElement();
                            for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
                                InetAddress inetAddress = enumIpAddr.nextElement();
                                if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
                                    hashMap.put("IP",inetAddress.getHostAddress());
                                    result.success(hashMap);

                                }
                            }
                        }
                    } catch (SocketException ex) {

                    }
                }
                catch (Exception e){
                    e.printStackTrace();
                }


            }

        }
        catch (Exception e){
            e.printStackTrace();
        }

        return false;
    }


    public void turnOffHotspot(){
        if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O) {
            if (mReservation != null) {
                mReservation.close();
            }
        }
        else{
            try {
                Method method = mWifiManager.getClass().getDeclaredMethod("setWifiApEnabled",
                        WifiConfiguration.class,Boolean.TYPE
                );
                method.invoke(mWifiManager,configuration,false);
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }

        }
    }
}
