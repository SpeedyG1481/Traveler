package com.mgs.traveler;
import com.chartboost.sdk.Chartboost;
import com.ironsource.mediationsdk.IronSource;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    public void onBackPressed() {
        if (!Chartboost.onBackPressed()) {
            super.onBackPressed();
        }
    }


    @Override
    public void onResume() {
        super.onResume();
        IronSource.onResume(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        IronSource.onPause(this);
    }

}
