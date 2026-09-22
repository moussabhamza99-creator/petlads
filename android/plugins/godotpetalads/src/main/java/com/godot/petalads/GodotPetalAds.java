package com.godot.petalads;

import android.app.Activity;
import android.graphics.Color;
import android.util.ArraySet;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.huawei.hms.ads.AdListener;
import com.huawei.hms.ads.AdParam;
import com.huawei.hms.ads.BannerAdSize;
import com.huawei.hms.ads.HwAds;
import com.huawei.hms.ads.banner.BannerView;
import com.huawei.hms.ads.interstitial.InterstitialAd;
import com.huawei.hms.ads.reward.Reward;
import com.huawei.hms.ads.reward.RewardAd;
import com.huawei.hms.ads.reward.RewardAdLoadListener;
import com.huawei.hms.ads.reward.RewardAdStatusListener;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.Set;

public class GodotPetalAds extends GodotPlugin {

    private static final String TAG = "GodotPetalAds";

    private FrameLayout layout;
    private BannerView bannerView;
    private InterstitialAd interstitialAd;
    private RewardAd rewardAd;

    public GodotPetalAds(Godot godot) {
        super(godot);
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "GodotPetalAds";
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new ArraySet<>();
        signals.add(new SignalInfo("on_banner_loaded"));
        signals.add(new SignalInfo("on_banner_failed", Integer.class));
        signals.add(new SignalInfo("on_banner_clicked"));

        signals.add(new SignalInfo("on_interstitial_loaded"));
        signals.add(new SignalInfo("on_interstitial_failed", Integer.class));
        signals.add(new SignalInfo("on_interstitial_opened"));
        signals.add(new SignalInfo("on_interstitial_closed"));

        signals.add(new SignalInfo("on_reward_loaded"));
        signals.add(new SignalInfo("on_reward_failed", Integer.class));
        signals.add(new SignalInfo("on_reward_opened"));
        signals.add(new SignalInfo("on_reward_closed"));
        signals.add(new SignalInfo("on_reward_earned", String.class, Integer.class));

        return signals;
    }

    @UsedByGodot
    public void initAds() {
        Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            HwAds.init(activity);
            Log.d(TAG, "Huawei Petal Ads SDK Initialized");
        });
    }

    // --- BANNER AD ---

    @UsedByGodot
    public void loadBanner(final String adId, final String position) {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            if (bannerView != null) {
                if (layout != null) {
                    layout.removeView(bannerView);
                }
                bannerView.destroy();
                bannerView = null;
            }

            bannerView = new BannerView(activity);
            bannerView.setAdId(adId);
            bannerView.setBannerAdSize(BannerAdSize.BANNER_SIZE_320_50);

            bannerView.setAdListener(new AdListener() {
                @Override
                public void onAdLoaded() {
                    Log.d(TAG, "Banner Ad loaded successfully.");
                    emitSignal("on_banner_loaded");
                }

                @Override
                public void onAdFailed(int errorCode) {
                    Log.e(TAG, "Banner Ad failed to load. Code: " + errorCode);
                    emitSignal("on_banner_failed", errorCode);
                }

                @Override
                public void onAdClicked() {
                    emitSignal("on_banner_clicked");
                }
            });

            if (layout == null) {
                layout = new FrameLayout(activity);
                activity.addContentView(layout, new FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                ));
            }

            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
            );

            if ("TOP".equalsIgnoreCase(position)) {
                layoutParams.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
            } else {
                layoutParams.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
            }

            layout.addView(bannerView, layoutParams);
            bannerView.setVisibility(View.GONE);

            AdParam adParam = new AdParam.Builder().build();
            bannerView.loadAd(adParam);
        });
    }

    @UsedByGodot
    public void showBanner() {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            if (bannerView != null) {
                bannerView.setVisibility(View.VISIBLE);
            }
        });
    }

    @UsedByGodot
    public void hideBanner() {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            if (bannerView != null) {
                bannerView.setVisibility(View.GONE);
            }
        });
    }

    // --- INTERSTITIAL AD ---

    @UsedByGodot
    public void loadInterstitial(final String adId) {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            interstitialAd = new InterstitialAd(activity);
            interstitialAd.setAdId(adId);
            interstitialAd.setAdListener(new AdListener() {
                @Override
                public void onAdLoaded() {
                    Log.d(TAG, "Interstitial Ad loaded.");
                    emitSignal("on_interstitial_loaded");
                }

                @Override
                public void onAdFailed(int errorCode) {
                    Log.e(TAG, "Interstitial Ad failed to load: " + errorCode);
                    emitSignal("on_interstitial_failed", errorCode);
                }

                @Override
                public void onAdOpened() {
                    emitSignal("on_interstitial_opened");
                }

                @Override
                public void onAdClosed() {
                    emitSignal("on_interstitial_closed");
                }
            });

            AdParam adParam = new AdParam.Builder().build();
            interstitialAd.loadAd(adParam);
        });
    }

    @UsedByGodot
    public void showInterstitial() {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            if (interstitialAd != null && interstitialAd.isLoaded()) {
                interstitialAd.show(activity);
            } else {
                Log.w(TAG, "Interstitial Ad is not ready to be shown.");
            }
        });
    }

    // --- REWARDED VIDEO AD ---

    @UsedByGodot
    public void loadRewardVideo(final String adId) {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            rewardAd = new RewardAd(activity, adId);
            RewardAdLoadListener listener = new RewardAdLoadListener() {
                @Override
                public void onRewardAdLoaded() {
                    Log.d(TAG, "Reward Ad loaded.");
                    emitSignal("on_reward_loaded");
                }

                @Override
                public void onRewardAdFailedToLoad(int errorCode) {
                    Log.e(TAG, "Reward Ad failed to load: " + errorCode);
                    emitSignal("on_reward_failed", errorCode);
                }
            };

            AdParam adParam = new AdParam.Builder().build();
            rewardAd.loadAd(adParam, listener);
        });
    }

    @UsedByGodot
    public void showRewardVideo() {
        final Activity activity = getActivity();
        if (activity == null) return;

        activity.runOnUiThread(() -> {
            if (rewardAd != null && rewardAd.isLoaded()) {
                rewardAd.show(activity, new RewardAdStatusListener() {
                    @Override
                    public void onRewardAdOpened() {
                        emitSignal("on_reward_opened");
                    }

                    @Override
                    public void onRewardAdClosed() {
                        emitSignal("on_reward_closed");
                    }

                    @Override
                    public void onRewarded(Reward reward) {
                        String name = reward != null ? reward.getName() : "Coins";
                        int amount = reward != null ? reward.getAmount() : 10;
                        Log.d(TAG, "Reward earned: " + amount + " " + name);
                        emitSignal("on_reward_earned", name, amount);
                    }

                    @Override
                    public void onRewardAdFailedToShow(int errorCode) {
                        Log.e(TAG, "Reward Ad failed to show: " + errorCode);
                    }
                });
            } else {
                Log.w(TAG, "Reward Ad is not loaded.");
            }
        });
    }
}
