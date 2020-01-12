package com.hosford.daniel.wildmagicsurge;

import android.os.Bundle;

import androidx.fragment.app.Fragment;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;


public class SurgeTextFragment extends Fragment {

    private TextView diceRoll, surgeValue;
    private String surgeString;
    private int diceValue;

    SurgeTextFragment(String s, int diceRoll) {
        this.diceValue = diceRoll;
        this.surgeString = s;

    }

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View mainView = inflater.inflate(R.layout.fragment_surge_text, container, false);
        diceRoll = mainView.findViewById(R.id.tvDiceRoll);
        surgeValue = mainView.findViewById(R.id.tvSurge);
        Log.wtf("fragment", surgeString + " : " + diceValue);
        setValues();
        return mainView;
    }

    private void setValues() {

        diceRoll.setText(String.valueOf(diceValue));
        surgeValue.setText(surgeString);
    }

}
