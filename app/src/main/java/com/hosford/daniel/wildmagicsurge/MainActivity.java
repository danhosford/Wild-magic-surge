package com.hosford.daniel.wildmagicsurge;


import androidx.appcompat.app.AppCompatActivity;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import java.util.Random;


public class MainActivity extends AppCompatActivity implements View.OnClickListener {
    private static final boolean AUTO_HIDE = true;
    private static final int AUTO_HIDE_DELAY_MILLIS = 3000;
    private static final int UI_ANIMATION_DELAY = 300;
    private final Handler mHideHandler = new Handler();
    private View mContentView;
    private String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fullscreen);
        findViewById(R.id.imageButton).setOnClickListener(this);
    }

    private void rollSurge() {
        Resources res = getResources();
        String[] surge = res.getStringArray(R.array.surge_array);
        Random rand = new Random();
        int upperbound=100;
        int diceRoll = rand.nextInt(upperbound);
        int surgeNumber = (int) Math.floor(diceRoll/2);
        showSurge(surge[surgeNumber], diceRoll, surgeNumber);
    }

    private void showSurge(String s, int diceRoll, int surgeNumber) {
        Log.i(TAG, "Random Number Generated: " + diceRoll);
        Log.i(TAG, surgeNumber + " : " + s);
        Toast toast = Toast.makeText(this, s, Toast.LENGTH_LONG);
        toast.show();
    }

    @Override
    public void onClick(View v) {
        switch(v.getId()) {
            case R.id.imageButton:
                rollSurge();
                break;
            default:
                break;
        }
    }
}
