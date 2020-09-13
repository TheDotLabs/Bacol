package com.github.amitkma.helloandroid;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.digidemic.unitof.UnitOf;

public class MainActivity extends Activity {
   @Override
   protected void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.activity_main);
      double feetToMeters = new UnitOf.Length().fromFeet(12.5).toMeters();
      TextView view = (TextView) findViewById(R.id.textview);
      view.setText("12.5 feet in meters: " + feetToMeters);
   }
}