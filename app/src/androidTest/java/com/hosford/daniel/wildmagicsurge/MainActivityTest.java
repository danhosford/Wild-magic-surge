package com.hosford.daniel.wildmagicsurge;

import android.view.View;

import androidx.test.espresso.Espresso;
import androidx.test.rule.ActivityTestRule;

import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import java.lang.annotation.Repeatable;

import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static org.junit.Assert.*;

public class MainActivityTest {

    @Rule
    public ActivityTestRule<MainActivity>mainActivityActivityTestRule = new ActivityTestRule<MainActivity>(MainActivity.class);

    private MainActivity mActivity = null;

    @Before
    public void setUp() throws Exception {
        mActivity = mainActivityActivityTestRule.getActivity();
    }

    @Test

    public void testLaunch(){
        View v = mActivity.findViewById(R.id.imageButton);
        assertNotNull(v);
    }

    @Test
    public void testSurgeButton(){
        for(int i =0; i<1000; i++){
            Espresso.onView(withId(R.id.imageButton)).perform(click());
        }
    }

    @After
    public void tearDown() throws Exception {
        mActivity = null;
    }
}