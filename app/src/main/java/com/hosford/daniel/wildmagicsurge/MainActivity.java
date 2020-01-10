package com.hosford.daniel.wildmagicsurge;


import androidx.appcompat.app.AppCompatActivity;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

import java.util.Random;


public class MainActivity extends AppCompatActivity implements View.OnTouchListener {
    private static final boolean AUTO_HIDE = true;
    private static final int AUTO_HIDE_DELAY_MILLIS = 3000;
    private static final int UI_ANIMATION_DELAY = 300;
    private final Handler mHideHandler = new Handler();
    private View mContentView;
    private boolean mVisible;
    private String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_fullscreen);

        mVisible = true;
        findViewById(R.id.imageButton).setOnTouchListener(this);

    }

    private void rollSurge() {
        Resources res = getResources();
        String[] surge = res.getStringArray(R.array.surge_array);
        Random rand = new Random();
        int upperbound=100;
        int diceRoll = rand.nextInt(upperbound);
        int surgeNumber = (int) Math.floor(diceRoll/2);
        Log.i(TAG, "Random Number Generated: " + diceRoll);
        Log.i(TAG, surgeNumber + " : " + surge[surgeNumber] );
        Toast toast = Toast.makeText(this, surge[surgeNumber], Toast.LENGTH_LONG);
        toast.show();
    }


    @Override
    public boolean onTouch(View v, MotionEvent event) {
        switch(v.getId()) {
            case R.id.imageButton:
                rollSurge();
                break;
             default:
                 break;
            }

        return false;
    }
}
