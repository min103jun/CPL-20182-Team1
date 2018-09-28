package com.player.jouncamp;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.PlaybackParams;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.MediaController;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.player.jouncamp.player.R;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Iterator;

import javax.net.ssl.HttpsURLConnection;


public class MainActivity extends AppCompatActivity implements SurfaceHolder.Callback, MediaController.MediaPlayerControl, MediaPlayer.OnPreparedListener, VideoControllerView.MediaPlayerControl, MediaPlayer.OnInfoListener{
    private long backKeyPressedTime = 0;
    private static final long backKeyTimeInterval = 2000;
    private SurfaceView surfaceView = null;
    private SurfaceHolder surfaceHolder = null;
    private MediaPlayer mediaPlayer;
    private Handler handler = new Handler();
    private ProgressDialog asyncDialog;
    private boolean changePlaySpeed = false;

    private VideoControllerView controller;
    private ScrollView allButtonContainer;

    private  static final double DEFAULT_VIDEO_RATIO = 0.5625;
    private static final long SLEEP_TIME_BEFORE_START_MILLIES = 1000;
    private static final int JUMP_BUTTON_INTERVAL_MILLIES = 3000;
    private static final int READ_TIMEOUT = 15000;
    private static final int CONNECT_TIMEOUT = 15000;
    private boolean isAuthenticated = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //인증 확인
        new CheckAuthenticatedUser().execute();
    }
    //초기설정 시작
    private void init() {
        //시청 시간을 기록하기 위한 시작시간
        GlobalVariables.appStartTime = System.currentTimeMillis();

        //각종 변수 초기화
        initVariables();
    }
    //변수들 초기화 함수
    private void initVariables() {

        initViewVariables();

        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(MainActivity.this);
        asyncDialog = new ProgressDialog(this);
        asyncDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        asyncDialog.setMessage(getString(R.string.now_loading));
        asyncDialog.setCancelable(false);
        controller = new VideoControllerView(this,GlobalVariables.fullLectureName);

        addListener();
    }

    //확인 버튼이 있는 대화창, error 전용 (제목이 error)
    private void popupAlertDialog(String text) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("error");
        builder.setMessage(text);
        builder.setPositiveButton(getString(R.string.confirm), null);
        builder.show();
    }

    //web javascript에서 intent로 실행된 url에서 정보를 추출
    private void getParamsFromUrl() {

        Uri uriData = getIntent().getData();

        try {
            //Globalvariables 클래스에 데이터 전달
            GlobalVariables.setParameters(uriData);
            GlobalVariables.parseParameters(this);
        } catch (Exception e) {
            e.printStackTrace();
            popupAlertDialog("URI parameter Error");
            finish();
        }
    }

    //뷰와 관련된 변수 초기화
    private void initViewVariables() {
        surfaceView = (SurfaceView) findViewById(R.id.surface_view);
        allButtonContainer = (ScrollView) findViewById(R.id.all_btn_container);

        //강의 이름이 없으면 강의 제목 표시를 하지 않음
        if (GlobalVariables.fullLectureName == null) {
            findViewById(R.id.txt_full_title).setVisibility(View.GONE);
        } else {
            ((TextView) findViewById(R.id.txt_full_title)).setText(GlobalVariables.fullLectureName );
        }
    }

    //모든 이벤트 리스너 추가 함수
    private void addListener() {
        //화면을 터치하면 동영상 컨트롤러 나타나기, 사라지기 에 대한 리스너
        surfaceView.setOnTouchListener(new View.OnTouchListener() {

            public boolean onTouch(View v, MotionEvent event) {
                v.performClick();
                if (controller != null) {
                    if (controller.isShowing()) {
                        controller.hide();
                    } else {
                        controller.show();
                    }
                }
                return false;
            }
        });
    }

    //일시정지, 재생 버튼 리스터
    public void onClickBtnPlayPauseToggle(View v) {
        if(mediaPlayer == null) return;
        if (mediaPlayer.isPlaying()) {
            pause();
        } else {
            start();
        }
    }


    //재생 시작
    @Override
    public void start() {

        new Thread() {
            public void run() {
                if(GlobalVariables.videoRatio == Double.NaN) {
                    Log.d("instart","Ratio nan");
                    handler.post(new Runnable(){
                        public void run() {
                            showToastMessage(getString(R.string.now_buffering));
                        }
                    });


                    while(GlobalVariables.videoRatio == Double.NaN) {
                        GlobalVariables.videoRatio = (double) Math.min(mediaPlayer.getVideoWidth(), mediaPlayer.getVideoHeight()) / Math.max(mediaPlayer.getVideoWidth(), mediaPlayer.getVideoHeight());
                        try {
                            sleep(200);

                        }
                        catch(Exception e) {
                            e.printStackTrace();
                        }
                    }
                    handler.post(new Runnable(){
                        public void run() {
                            showToastMessage(getString(R.string.now_buffering));
                            if(GlobalVariables.mFullScreen == false) {
                                surfaceView.getLayoutParams().height = (int) (Math.max(surfaceView.getWidth(), surfaceView.getHeight()) * GlobalVariables.videoRatio);
                                surfaceView.requestLayout();
                            }

                        }
                    });
                }
            }
        }.start();


        mediaPlayer.start();
        controller.updatePausePlay();
        Log.d("start()", "cannot start");

    }

    //일시정지
    @Override
    public void pause() {
        mediaPlayer.pause();
        controller.updatePausePlay();
    }

    //현재 재생중인 영상의 길이
    @Override
    public int getDuration() {
        try {
            return mediaPlayer.getDuration();
        } catch (Exception e) {
            return 0;
        }
    }

    //현재 재생중인 위치 (밀리초)
    @Override
    public int getCurrentPosition() {
        try {
            return mediaPlayer.getCurrentPosition();
        } catch (Exception e) {
            return 0;
        }
    }

    //특정 위치로 이동 (밀리초)
    @Override
    public void seekTo(int pos) {

        if (mediaPlayer.getDuration() <= pos) {
            pos = mediaPlayer.getDuration() - 1000;
        }
        if (pos < 0) pos = 0;
        mediaPlayer.seekTo(pos);
    }
    //재생 중인지
    @Override
    public boolean isPlaying() {
        try {
            return mediaPlayer.isPlaying();
        } catch (Exception e) {
            return false;
        }
    }
    //미사용
    @Override
    public int getBufferPercentage() {
        return 0;
    }
    //미사용
    @Override
    public boolean canPause() {
        return true;
    }
    //미사용
    @Override
    public boolean canSeekBackward() {
        return true;
    }
    //미사용
    @Override
    public boolean canSeekForward() {
        return true;
    }
    //가로화면인지 검사
    @Override
    public boolean isFullScreen() {
        return GlobalVariables.mFullScreen;
    }

    //화면전환
    @Override
    public void toggleFullScreen() {
        GlobalVariables.changeScreen = true;
        GlobalVariables.clickedToggle = true;
        controller.hide();
        setFullScreen();

    }

    public void setFullScreen() {

        if (!GlobalVariables.mFullScreen) // 현재가 풀스크린이 아니면 풀스크린으로 만들기
        {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
            GlobalVariables.mFullScreen = true;
            controller.hide();
            allButtonContainer.setVisibility(View.GONE);

        } else if (GlobalVariables.mFullScreen) {
            controller.hide();
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
            GlobalVariables.mFullScreen = false;
            allButtonContainer.setVisibility(View.VISIBLE);
        }
    }

    //미사용
    @Override
    public int getAudioSessionId() {
        return mediaPlayer.getAudioSessionId();
    }

    //비디오 시작
    public void startVideo() {
        if (mediaPlayer != null)
            mediaPlayer.release();

        //미디어 플레이어가 이미 할당되어 있으면 새로 재생 불가능
        //release후 재할당
        mediaPlayer = new MediaPlayer();
        mediaPlayer.setDisplay(surfaceHolder);
        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        mediaPlayer.setOnPreparedListener(MainActivity.this);
        mediaPlayer.setOnInfoListener(MainActivity.this);

        try {
            mediaPlayer.setDataSource(GlobalVariables.getParam(getString(R.string.param_name_lecture_video_url_container)));
            mediaPlayer.prepareAsync();

        } catch (Exception e) {
            e.printStackTrace();
            dismissProgressDialog();
            showToastMessage(getString(R.string.fatal_error));
            finish();
        }
    }

    //하단 토스트 메시지 출력
    public void showToastMessage(String message) {
        Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT).show();
    }

    //재생 속도 조정
    public void adjustPlaySpeed(float speed) {
        //현재 재생 위치 기록후 미디어 재실행
        //재생 중 재생속도 조정하기는 불가능
        //추후 방법이 생기면 수정

        GlobalVariables.playSpeed = speed;
        GlobalVariables.lastPlayTime = mediaPlayer.getCurrentPosition() / 1000;
        changePlaySpeed = true;
        startVideo();
    }
    //mediaplayer 객체가 재생이 준비 완료되면 실행 되는 callback 함수
    @Override
    public void onPrepared(MediaPlayer mp) {

        //컨트롤러 부착착
        controller.setMediaPlayer(this);
        controller.setAnchorView((FrameLayout) findViewById(R.id.video_surface_container));
        controller.setEnabled(true);

        //재생속도 적용 코드
        //안드로이드 6.0 부터 적용가능
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M ) {
            PlaybackParams playbackParams = mediaPlayer.getPlaybackParams();
            playbackParams.setSpeed(GlobalVariables.playSpeed);
            mediaPlayer.setPlaybackParams(playbackParams);
        }

        //이어보기 Y N
        String decision = GlobalVariables.getParam(getString(R.string.param_name_lecture_previous_play_decision));
        GlobalVariables.setParam(getString(R.string.param_name_lecture_previous_play_decision),"C");
        if (decision != null)
            decision = decision.trim().toUpperCase();

        //재생속도 변경이 아닐경우 (첫 실행시)
        if (!changePlaySpeed) {

            GlobalVariables.lastPlayTime = 0;
            Log.d("decision",decision);
            if(decision != null && decision.equals("Y")) {
                AlertDialog.Builder ab = new AlertDialog.Builder(this);
                ab.setTitle(getString(R.string.continue_dialog_title));
                ab.setMessage(getString(R.string.continue_dialog_inner_text));
                ab.setCancelable(false);
                ab.setPositiveButton(getString(R.string.yes), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        try {
                            GlobalVariables.lastPlayTime = Integer.parseInt(GlobalVariables.getParam(getString(R.string.param_name_lecture_previous_play_time)));

                        } catch (NumberFormatException e) {
                            e.printStackTrace();
                            GlobalVariables.lastPlayTime = 0;
                        }
                        showProgressDialog();
                        startAfterSleep();
                    }
                });
                ab.setNegativeButton(getString(R.string.no), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        GlobalVariables.lastPlayTime = 0;
                        showProgressDialog();
                        startAfterSleep();
                    }
                });
                ab.show();
            }
            else {
                startAfterSleep();
            }


        } else if (changePlaySpeed) {
            //showProgressDialog();
            startAfterSleep();
        }

    }
    //비디오 재생
    //잠깐 sleep 하고 재생한다 (로딩 시간을 주기위함)
    public void startAfterSleep() {
        this.seekTo(GlobalVariables.lastPlayTime * 1000);

        mediaPlayer.start();

        if(GlobalVariables.videoRatio == Double.NaN) {
            GlobalVariables.videoRatio = (double) Math.min(mediaPlayer.getVideoWidth(), mediaPlayer.getVideoHeight()) / Math.max(mediaPlayer.getVideoWidth(), mediaPlayer.getVideoHeight());
        }

        if (GlobalVariables.changeScreen) {
            GlobalVariables.changeScreen = false;
            return;
        }
        mediaPlayer.pause();
        new Thread() {
            public void run() {
                try {
                    sleep(SLEEP_TIME_BEFORE_START_MILLIES);

                    dismissProgressDialog();
                    if (!changePlaySpeed) {
                        Log.d("videoRatio", GlobalVariables.videoRatio + "");
                        for(int i = 0 ;i < 5; i++) {
                            Log.d("media width",mediaPlayer.getVideoWidth() + "");
                            Log.d("media height",mediaPlayer.getVideoHeight() + "");


                            GlobalVariables.videoRatio = (double) Math.min(mediaPlayer.getVideoWidth(), mediaPlayer.getVideoHeight()) / Math.max(mediaPlayer.getVideoWidth(), mediaPlayer.getVideoHeight());


                            sleep(200);
                            Log.d("videoRatio",GlobalVariables.videoRatio + "");
                            if(0 < GlobalVariables.videoRatio && GlobalVariables.videoRatio < 1) break;
                        }
                        if(GlobalVariables.videoRatio == 1.0 || GlobalVariables.videoRatio == 0.0) {
                            GlobalVariables.videoRatio = DEFAULT_VIDEO_RATIO;
                        }
                        Log.d("videorato", GlobalVariables.videoRatio + "");
                        if(GlobalVariables.videoRatio == Double.NaN) {
                            GlobalVariables.videoRatio = 1.0;
                        }
                        handler.post(new Runnable() {
                            public void run() {
                                try {
                                    if (getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE) {

                                        surfaceView.getLayoutParams().height = (int) (Math.max(surfaceView.getWidth(), surfaceView.getHeight()) * GlobalVariables.videoRatio);
                                    }
                                    surfaceView.requestLayout();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    }
                    mediaPlayer.start();
                    changePlaySpeed = false;

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }.start();
    }

    //로딩중 다이얼로그를 띄운다
    public void showProgressDialog() {
        //main ui 스레드가 아닌 다른 스레드에서 ui작업 호출 시
        //handler로 요청을 해 주어야 한다.
        //그냥 요청시 error
        handler.post(new Runnable() {
            public void run() {
                try {
                    if (asyncDialog != null)
                        asyncDialog.show();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    //로딩중 다이얼로그를 없앤다
    public void dismissProgressDialog() {
        handler.post(new Runnable() {
            public void run() {
                try {
                    if (asyncDialog != null)
                        asyncDialog.dismiss();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    //1.0 배속 버튼
    public void onClickBtn1_0Speed(View v) {
        if (GlobalVariables.playSpeed == 1f) {
            return;
        }

        adjustPlaySpeed(1f);
    }

    //1.2 배속 버튼
    public void onClickBtn1_2Speed(View v) {
        if (GlobalVariables.playSpeed == 1.2f) {
            return;
        }
        adjustPlaySpeed(1.2f);
    }
    //1.4 배속 버튼
    public void onClickBtn1_4Speed(View v) {
        if (GlobalVariables.playSpeed == 1.4f) {
            return;
        }

        adjustPlaySpeed(1.4f);
    }
    //1.6 배속 버튼
    public void onClickBtn1_6Speed(View v) {
        if (GlobalVariables.playSpeed == 1.6f) {
            return;
        }

        adjustPlaySpeed(1.6f);
    }
    //1.8 배속 버튼
    public void onClickBtn1_8Speed(View v) {
        if (GlobalVariables.playSpeed == 1.8f) {
            return;
        }

        adjustPlaySpeed(1.8f);
    }
    // 2.0 배속 버튼
    public void onClickBtn2_0Speed(View v) {
        if (GlobalVariables.playSpeed == 2.0f) {
            return;
        }

        adjustPlaySpeed(2.0f);
    }


    //이전, 이후 점프 버튼 (플레이어 내)
    public void onClickBtnBackJump(View v) {
        seekTo(mediaPlayer.getCurrentPosition() - JUMP_BUTTON_INTERVAL_MILLIES);
    }

    public void onClickBtnForwardJump(View v) {
        seekTo(mediaPlayer.getCurrentPosition() + JUMP_BUTTON_INTERVAL_MILLIES);
    }

    //화면상에 surface view가 완전히 그려졌을때 실행되는 callback
    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        Log.d("surfaceCreated", "created");
        startVideo();
    }


    //surface view의 크기가 변경 되었을때 실행되는 callback
    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }


    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {

    }


    @Override
    protected void onPause() {
        if (mediaPlayer != null) {
            pause();
        }
        super.onPause();
        Log.d("pause", "onPause");
    }

    protected void onRestart() {
        super.onRestart();
        if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            toLandscape();
        }
        else {
            toPortrait();
        }
        Log.d("onRestart","onRestart");
    }
    protected void onResume() {
        super.onResume();

        if (mediaPlayer != null) {
            start();
        }
        Log.d("resume", "onResume");

    }

    @Override
    protected void onStop() {
        super.onStop();
        if (GlobalVariables.changeScreen) {
            GlobalVariables.lastPlayTime = mediaPlayer.getCurrentPosition() / 1000;
            return;
        }
        if (mediaPlayer != null) {
            GlobalVariables.lastPlayTimeInSecForEnd = mediaPlayer.getCurrentPosition() / 1000;

            new SendPostRequest().execute("end");

            //mediaPlayer.pause();
            //mediaPlayer.stop();
            //mediaPlayer.release();
            //mediaPlayer = null;
            Log.d("stop", "onStop()");
        }
    }

    //어플이 완전히 메모리에서 제거될때 실행되는 콜백
    protected void onDestroy() {
        super.onDestroy();
    }

    //가로화면으로 전환
    public void toLandscape() {
        GlobalVariables.mFullScreen = true;
        if(!isAuthenticated) {
            Log.d("toLandscape()","not yet authenticated");
            return;
        }
        if(controller != null)
            controller.hide();
        if(allButtonContainer != null)
            allButtonContainer.setVisibility(View.GONE);
        if(surfaceView != null) {
            surfaceView.getLayoutParams().height = ViewGroup.LayoutParams.MATCH_PARENT;
            surfaceView.requestLayout();
        }
        //상단바 제거
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

    }

    //세로화면으로 전환환
    public void toPortrait() {
        if(controller != null)
            controller.hide();
        GlobalVariables.mFullScreen = false;
        if(allButtonContainer != null)
            allButtonContainer.setVisibility(View.VISIBLE);

        //상단바 나타내기
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

        if(surfaceView != null)
            surfaceView.getLayoutParams().height = (int) ((float) surfaceView.getHeight() * GlobalVariables.videoRatio);
    }

    //배속조정 버튼 리스너 부착
    //가로화면에서의 컨트롤러 클릭 리스너
    @Override
    public void onClick1_0Listener() {
        onClickBtn1_0Speed(null);
    }

    @Override
    public void onClick1_2Listener() {
        onClickBtn1_2Speed(null);
    }

    @Override
    public void onClick1_4Listener() {
        onClickBtn1_4Speed(null);
    }

    @Override
    public void onClick1_6Listener() {
        onClickBtn1_6Speed(null);
    }

    @Override
    public void onClick1_8Listener() {
        onClickBtn1_8Speed(null);
    }

    @Override
    public void onClick2_0Listener() {
        onClickBtn2_0Speed(null);
    }

    //화면 가로모드-세로모드 전환 됐을때 실행되는 콜백함수
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        //화면을 돌린것이 아닌 전체화면 버튼을 눌렀을떄
        //현재는 처리의 애매함으로 버튼을 숨겨둠
        if (GlobalVariables.clickedToggle) {

            if (GlobalVariables.mFullScreen) {
                allButtonContainer.setVisibility(View.GONE);
            } else {
                allButtonContainer.setVisibility(View.VISIBLE);
            }
            GlobalVariables.clickedToggle = false;
            return;
        }

        //화면돌렸을때
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            toLandscape();
        } else {
            toPortrait();
        }
        //플레이어 내부 뷰들을 가로/세로에 맞는 화면으로 전환
        if(controller != null)
            controller.updateFullScreen();
    }

    private String getPostDataString(JSONObject params) throws Exception {

        StringBuilder result = new StringBuilder();
        boolean first = true;

        Iterator<String> itr = params.keys();

        while (itr.hasNext()) {

            String key = itr.next();
            Object value = params.get(key);

            if (first)
                first = false;
            else
                result.append("&");

            result.append(URLEncoder.encode(key, "UTF-8"));
            result.append("=");
            result.append(URLEncoder.encode(value.toString(), "UTF-8"));

        }
        return result.toString();
    }


    //현재 플레이어의 상태를 받아온느 콜백 함수
    //MEDIA_INFO_BUFFERING_START : 버퍼링 시작
    //MEDIA_INFO_BUFFERING_END : 버퍼링 종료
    @Override
    public boolean onInfo(MediaPlayer mp,int what, int extraA) {

        if(what == MediaPlayer.MEDIA_INFO_BUFFERING_START) {
            showToastMessage(getString(R.string.now_buffering));
        }
        else if(what == MediaPlayer.MEDIA_INFO_BUFFERING_END) {

        }


        return false;
    }

    //인증된 회사인지 확인
    class CheckAuthenticatedUser extends AsyncTask<String, Void, String> {
        URL url = null;

        //인증 확인 절차를 보내기 전에 intent에서 파라미터 추출
        protected void onPreExecute() {
            getParamsFromUrl();
        }

        protected String doInBackground(String... arg0) {

            HttpURLConnection conn = null;
            JSONObject postDataParams = null;

            try {

                url = new URL(getString(R.string.authenfication_url));
                Log.d("url", url.toString());
                postDataParams = new JSONObject();

                postDataParams.put(getString(R.string.authentication), GlobalVariables.getParam(getString(R.string.authentication)));
                Log.d("data", postDataParams.toString());

                conn = (HttpURLConnection) url.openConnection();

                conn.setReadTimeout(READ_TIMEOUT /* milliseconds */);
                conn.setConnectTimeout(CONNECT_TIMEOUT /* milliseconds */);
                conn.setRequestMethod("POST");
                //conn.setRequestProperty("Cookie",cookie);
                conn.setDoInput(true);
                conn.setDoOutput(true);
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (conn == null) return null;

            OutputStream os;
            BufferedWriter writer;
            try {
                os = conn.getOutputStream();
                writer = new BufferedWriter(
                        new OutputStreamWriter(os, "UTF-8"));
                writer.write(getPostDataString(postDataParams));
                writer.flush();
                writer.close();
                os.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            StringBuffer sb = null;
            try {
                int responseCode = conn.getResponseCode();

                if (responseCode == HttpsURLConnection.HTTP_OK) {

                    BufferedReader in = new BufferedReader(
                            new InputStreamReader(
                                    conn.getInputStream()));
                    sb = new StringBuffer("");
                    String line;

                    while ((line = in.readLine()) != null) {
                        sb.append(line);
                    }

                    in.close();
                } else {
                    Log.i("response", "" + responseCode);
                    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(getApplicationContext());

                    alertDialogBuilder.setTitle(getString(R.string.unauthenticated_uses));
                    alertDialogBuilder.setMessage(getString(R.string.request_the_developer)).setCancelable(false);
                    alertDialogBuilder.setPositiveButton(getString(R.string.confirm), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {

                            finish();
                        }
                    });
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (sb == null) {
                return null;
            }
            return sb.toString();

        }

        protected void onPostExecute(String result) {
            Log.d("authentication res", result);
            if (result == null) {
                popupAlertDialog("서버에러입니다");
                finish();
                return;
            }
            Log.d("authentication res", result);
            if (result.equals(getString(R.string.authentication_false))) {
                isAuthenticated = false;
                AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
                builder.setTitle("unauthenticated uses");
                builder.setMessage(getString(R.string.unauthenticated_uses) + getString(R.string.request_the_developer));
                builder.setPositiveButton(getString(R.string.confirm), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {

                        finish();
                    }
                });
                builder.show();
            } else {
                setContentView(R.layout.activity_main);

                isAuthenticated = true;
                init();

                //6.0 아래버전은 배속기능 지원하지않음, 따라서 배속 설정버튼 숨김
                if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
                    findViewById(R.id.linear_speed_container).setVisibility(View.GONE);
                }

                //최초 실행시에 가로 세로인지 판단
                if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
                    allButtonContainer.setVisibility(View.GONE);
                    GlobalVariables.mFullScreen = true;
                    controller.updateFullScreen();
                    getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
                }
                showProgressDialog();

            }

        }
    }

    public void onBackPressed() {

        if(System.currentTimeMillis() > backKeyPressedTime + backKeyTimeInterval) {
            backKeyPressedTime = System.currentTimeMillis();
            showToastMessage(getString(R.string.guide_back_pressed));
            return;
        }
        finish();
    }

    class SendPostRequest extends AsyncTask<String, Void, String> {

        private URL url = null;

        public SendPostRequest() {
        }


        protected void onPreExecute() {
        }

        protected String doInBackground(String... arg0) {
            if (!isAuthenticated) return null;

            if (GlobalVariables.requestUrlForEnd == null) {
                return null;
            }

            HttpURLConnection conn = null;
            JSONObject postDataParams = null;

            try {

                url = new URL(GlobalVariables.requestUrlForEnd);
                Log.d("end URL", GlobalVariables.requestUrlForEnd);
                postDataParams = new JSONObject(GlobalVariables.getParam("json_data"));

                postDataParams.put("run_time", (System.currentTimeMillis() - GlobalVariables.appStartTime) / 1000);
                postDataParams.put("last_play_time", GlobalVariables.lastPlayTimeInSecForEnd);

                conn = (HttpURLConnection) url.openConnection();
                conn.setReadTimeout(READ_TIMEOUT /* milliseconds */);
                conn.setConnectTimeout(CONNECT_TIMEOUT /* milliseconds */);
                conn.setRequestMethod("POST");
                //conn.setRequestProperty("Cookie",cookie);
                conn.setDoInput(true);
                conn.setDoOutput(true);


            } catch (Exception e) {
                e.printStackTrace();
            }
            if (conn == null) return null;
            OutputStream os;
            BufferedWriter writer;

            try {
                os = conn.getOutputStream();
                writer = new BufferedWriter(
                        new OutputStreamWriter(os, "UTF-8"));
                writer.write(getPostDataString(postDataParams));

                writer.flush();
                writer.close();
                os.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            StringBuffer sb = null;
            try {
                int responseCode = conn.getResponseCode();

                if (responseCode == HttpsURLConnection.HTTP_OK) {

                    BufferedReader in = new BufferedReader(
                            new InputStreamReader(
                                    conn.getInputStream()));
                    sb = new StringBuffer("");
                    String line;
                    while ((line = in.readLine()) != null) {
                        sb.append(line);
                    }

                    in.close();
                } else {
                    Log.i("response", "" + responseCode);
                    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(getApplicationContext());

                    alertDialogBuilder.setTitle(getString(R.string.server_error));
                    alertDialogBuilder.setMessage(getString(R.string.server_error_exit_the_application)).setCancelable(false);
                    alertDialogBuilder.setPositiveButton(getString(R.string.confirm), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {

                            finish();
                        }
                    });
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (sb == null) {
                return null;
            }
            return sb.toString();
        }


        @Override
        protected void onPostExecute(String result) {

            //finish();
        }
    }

}
