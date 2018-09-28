package com.player.jouncamp;

import android.content.Context;
import android.content.res.Resources;
import android.net.Uri;
import android.util.Log;

import com.player.jouncamp.player.R;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;



//프로그램 전체에서 쓰이는 변수들.
public class GlobalVariables {


    static boolean mFullScreen = false;
    //public static String videoUrl = null;
    static int lastPlayTime = 0;
    static boolean changeScreen = false;
    static boolean clickedToggle = false;
    static int lastPlayTimeInSecForEnd = 0;
    static long appStartTime = 0;
    static float playSpeed = 1.0f;

    static Map<String, String> parametersMap = new HashMap<>();

    static String fullLectureName = null;

    //어플 종료시에 보던 시점 보낼 주소
    static String requestUrlForEnd = null;


    static double videoRatio = 1.0;

    static void setFullLectureName(String name) {
        fullLectureName = name;
    }

    static String getParam(String key) {
        return parametersMap.get(key);
    }

    static void setParam(String key, String value) {
        parametersMap.put(key,value);
    }
    static void parseParameters(Context context) {
        String tempFullLectureName = null;
        //데이터 셋팅 후 강의 제목 설정
        if(GlobalVariables.getParam(context.getString(R.string.param_name_lecture_number)) != null) {
            tempFullLectureName = GlobalVariables.getParam(context.getString(R.string.param_name_lecture_number));
            if(GlobalVariables.getParam(context.getString(R.string.param_name_lecture_unit)) != null) {
                tempFullLectureName += GlobalVariables.getParam(context.getString(R.string.param_name_lecture_unit));
            }
            tempFullLectureName += "-";
        }

        if (GlobalVariables.getParam(context.getString(R.string.param_name_lecture_title)) != null) {
            tempFullLectureName += GlobalVariables.getParam(context.getString(R.string.param_name_lecture_title));
        }

        GlobalVariables.setFullLectureName(tempFullLectureName);
        //끝날때 종료정보 전달 url 설정

        GlobalVariables.requestUrlForEnd = GlobalVariables.getParam(context.getString(R.string.url_for_end));
    }
    static void setParameters(Uri uriData) {
        Log.d("uriData",uriData.toString());
        Iterator<String> iter = uriData.getQueryParameterNames().iterator();
        while(iter.hasNext()) {
           String key = iter.next();
           String value = uriData.getQueryParameter(key);
           GlobalVariables.parametersMap.put(key,value);
           Log.d("key-value",key + " " + value);
        }
    }
}
