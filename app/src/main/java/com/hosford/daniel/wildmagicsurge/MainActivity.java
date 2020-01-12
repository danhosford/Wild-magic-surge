package com.hosford.daniel.wildmagicsurge;


import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import android.content.res.Resources;
import android.os.Bundle;
import android.view.View;


import java.util.Objects;
import java.util.Random;


public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try
        {
            Objects.requireNonNull(this.getSupportActionBar()).hide();
        }
        catch (NullPointerException e){
            e.printStackTrace();
        }
        setContentView(R.layout.activity_fullscreen);
        findViewById(R.id.btnSurge).setOnClickListener(this);
    }

    public void rollSurge() {
        Resources res = getResources();
        String[] surge = res.getStringArray(R.array.surge_array);
        Random rand = new Random();
        int upperbound=100;
        int diceRoll = rand.nextInt(upperbound);
        int surgeNumber = (int) Math.floor(diceRoll/2);
        showSurge(surge[surgeNumber], diceRoll);
    }

    private void showSurge(String s, int diceRoll) {
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        SurgeTextFragment fragment = new SurgeTextFragment(s, diceRoll);
        fragmentTransaction.add(R.id.fragment_frame, fragment);
        fragmentTransaction.commit();
    }


    @Override
    public void onClick(View v) {
        switch(v.getId()) {
            case R.id.btnSurge:
                rollSurge();
                break;
            default:
                break;
        }
    }
}
