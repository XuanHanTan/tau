/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

/// ------------------------------------------------------------------
///
/// # [SoundPlayerUI] is a HTML 5 style audio play bar.
/// It allows you to play/pause/resume and seek an audio track.
///
/// The `SoundPlayerUI` displays:
/// -  a spinner while loading audio
/// -  play/resume buttons
/// -  a slider to indicate and change the current play position.
/// -  optionally displays the album title and track if the
///   [Track] contains those details.
///
/// ------------------------------------------------------------------
///
/// {@category UI_Widgets}
library ui_player;

import 'dart:async';
import 'dart:ui';
//import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../flutter_sound.dart';

///
typedef OnLoad = Future<Track> Function(BuildContext context);

/// -----------------------------------------------------------------
/// # A HTML 5 style audio play bar.
///
/// Allows you to play/pause/resume and seek an audio track.
/// The `SoundPlayerUI` displays:
/// -  a spinner while loading audio
/// -  play/resume buttons
/// -  a slider to indicate and change the current play position.
/// -  optionally displays the album title and track if the
///   [Track] contains those details.
///
/// -----------------------------------------------------------------
///

class SoundPlayerUI extends StatefulWidget {
  /// only codec support by android unless we have a minSdk of 29
  /// then OGG_VORBIS and OPUS are supported.
  static const Codec standardCodec = Codec.aacADTS;
  static const int _barHeight = 60;

  final OnLoad? _onLoad;
  final Track? _track;
  final bool _showTitle;
  final bool _enabled;

  final Color? _backgroundColor;
  final Color? _accentColor;
  final Color _iconColor;
  final Color _disabledIconColor;
  final TextStyle? _textStyle;
  final TextStyle? _titleStyle;
  final SliderThemeData? _sliderThemeData;
  final int? _rectime;
  final double _iconRadius;
  final double _iconSplashRadius;
  final Function? _whenPlayStart;
  final Color _textColor;

// -----------------------------------------------------------------------------------------------------------

  /// [SoundPlayerUI.fromLoader] allows you to dynamically provide
  /// a [Track] when the user clicks the play
  /// button.
  /// You can cancel the play action by returning
  /// null when _onLoad is called.
  /// [onLoad] is the function that is called when the user clicks the
  /// play button. You return either a Track to be played or null
  /// if you want to cancel the play action.
  /// If [showTitle] is true (default is false) then the play bar will also
  /// display the track name and album (if set).
  /// If [enabled] is true (the default) then the Player will be enabled.
  /// If [enabled] is false then the player will be disabled and the user
  /// will not be able to click the play button.
  /// The [audioFocus] allows you to control what happens to other
  /// media that is playing when our player starts.
  /// By default we use `AudioFocus.requestFocusAndDuckOthers` which will
  /// reduce the volume of any other players.
  SoundPlayerUI.fromLoader(OnLoad onLoad,
      {bool showTitle = false,
      bool enabled = true,
      AudioFocus audioFocus = AudioFocus.requestFocusAndKeepOthers,
      Color? backgroundColor,
      Color? accentColor,
      Color iconColor = Colors.black,
      Color disabledIconColor = Colors.grey,
      TextStyle? textStyle,
      TextStyle? titleStyle,
      SliderThemeData? sliderThemeData,
      int? rectime,
      double iconRadius = 24,
      Function? whenPlayStart,
      double iconSplashRadius = 20,
      Color textColor = Colors.black})
      : _onLoad = onLoad,
        _showTitle = showTitle,
        _track = null,
        _enabled = enabled,
        _backgroundColor =
            (backgroundColor == null) ? Color(0xFFFAF0E6) : backgroundColor,
        _accentColor = accentColor ?? Color(0xFFFAF0E6),
        _iconColor = iconColor,
        _disabledIconColor = disabledIconColor,
        _textStyle = textStyle,
        _titleStyle = titleStyle,
        _sliderThemeData = sliderThemeData,
        _rectime = rectime,
        _iconRadius = iconRadius,
        _whenPlayStart = whenPlayStart,
        _iconSplashRadius = iconSplashRadius,
        _textColor = textColor;

  ///
  /// [SoundPlayerUI.fromTrack] Constructs a Playbar with a Track.
  /// `track` is the Track that contains the audio to play.
  ///
  /// When the user clicks the play the audio held by the Track will
  /// be played.
  /// If `showTitle` is true (default is false) then the play bar will also
  /// display the track name and album (if set).
  /// If `enabled` is true (the default) then the Player will be enabled.
  /// If `enabled` is false then the player will be disabled and the user
  /// will not be able to click the play button.
  /// The `audioFocus` allows you to control what happens to other
  /// media that is playing when our player starts.
  /// By default we use 'AudioFocus.focusAndHushOthers` which will
  /// reduce the volume of any other players.
  SoundPlayerUI.fromTrack(Track track,
      {bool showTitle = false,
      bool enabled = true,
      AudioFocus audioFocus = AudioFocus.requestFocusAndKeepOthers,
      Color? backgroundColor,
      Color? accentColor,
      Color iconColor = Colors.black,
      Color disabledIconColor = Colors.grey,
      TextStyle? textStyle,
      TextStyle? titleStyle,
      SliderThemeData? sliderThemeData,
      int? rectime,
      double iconRadius = 24,
      Function? whenPlayStart,
      double iconSplashRadius = 20,
      Color textColor = Colors.black})
      : _track = track,
        _showTitle = showTitle,
        _onLoad = null,
        _enabled = enabled,
        _backgroundColor = backgroundColor,
        _accentColor = accentColor,
        _iconColor = iconColor,
        _disabledIconColor = disabledIconColor,
        _textStyle = textStyle,
        _titleStyle = titleStyle,
        _sliderThemeData = sliderThemeData,
        _rectime = rectime,
        _iconRadius = iconRadius,
        _whenPlayStart = whenPlayStart,
        _iconSplashRadius = iconSplashRadius,
        _textColor = textColor;

  @override
  State<StatefulWidget> createState() {
    return SoundPlayerUIState(_track, _onLoad,
        enabled: _enabled,
        backgroundColor:
            (_backgroundColor != null) ? _backgroundColor : Color(0xFFFAF0E6),
        accentColor: _accentColor ?? Color(0xFFFAF0E6),
        iconColor: _iconColor,
        disabledIconColor: _disabledIconColor,
        textStyle: _textStyle,
        titleStyle: _titleStyle,
        sliderThemeData: _sliderThemeData,
        rectime: _rectime,
        iconRadius: _iconRadius,
        whenPlayStart: _whenPlayStart,
        iconSplashRadius: _iconSplashRadius,
        textColor: _textColor);
  }
}

// ------------------------------------------------------------------------------------------------------------------

/// internal state.
/// @nodoc
class SoundPlayerUIState extends State<SoundPlayerUI>
    with TickerProviderStateMixin {
  final FlutterSoundPlayer _player;

  final _sliderPosition = _SliderPosition();

  /// we keep our own local stream as the players come and go.
  /// This lets our StreamBuilder work without  worrying about
  /// the player's stream changing under it.
  final StreamController<PlaybackDisposition> _localController;

  // we are current play (but may be paused)
  _PlayState __playState = _PlayState.stopped;

  // Indicates that we have start a transition (play to pause etc)
  // and we should block user interaction until the transition completes.
  bool __transitioning = false;

  /// indicates that we have started the player but we are waiting
  /// for it to load the audio resource.
  bool __loading = false;

  /// the [Track] we are playing .
  /// If the fromLoader ctor is used this will be null
  /// until the user clicks the Play button and onLoad
  /// returns a non null [Track]
  Track? _track;
  Duration? seekPos;
  final OnLoad? _onLoad;
  AnimationController? playButtonAnimationController;
  final bool? _enabled;
  final Function? _whenPlayStart;
  final Color? _backgroundColor;
  final Color? _accentColor;
  final Color? _iconColor;

  final Color? _disabledIconColor;

  final TextStyle? _textStyle;

  final TextStyle? _titleStyle;

  StreamSubscription? _playerSubscription;

  final SliderThemeData? _sliderThemeData;

  final int? _rectime;
  final double _iconRadius;
  final double _iconSplashRadius;
  final Color _textColor;

  ///
  SoundPlayerUIState(this._track, this._onLoad,
      {bool? enabled,
      Color? backgroundColor,
      Color? accentColor,
      Color? iconColor,
      Color? disabledIconColor,
      TextStyle? textStyle,
      TextStyle? titleStyle,
      SliderThemeData? sliderThemeData,
      int? rectime,
      double iconRadius = 24,
      Function? whenPlayStart,
      double iconSplashRadius = 20,
      Color textColor = Colors.black})
      : _player = FlutterSoundPlayer(),
        _enabled = enabled,
        _backgroundColor = backgroundColor,
        _accentColor = accentColor,
        _iconColor = iconColor,
        _disabledIconColor = disabledIconColor,
        _textStyle = textStyle,
        _titleStyle = titleStyle,
        _sliderThemeData = sliderThemeData,
        _rectime = rectime,
        _iconRadius = iconRadius,
        _whenPlayStart = whenPlayStart,
        _iconSplashRadius = iconSplashRadius,
        _textColor = textColor,
        _localController = StreamController<PlaybackDisposition>.broadcast() {

      _sliderPosition.position = Duration(seconds: 0);
    _sliderPosition.maxPosition = Duration(milliseconds: _rectime!);

    if (!_enabled!) {
      __playState = _PlayState.disabled;
    }
    seekPos = null;
    _player
        .openAudioSession(
            focus: AudioFocus.requestFocusAndDuckOthers,
            category: SessionCategory.playAndRecord,
            mode: SessionMode.modeDefault,
            device: AudioDevice.speaker,
            audioFlags: outputToSpeaker | allowBlueToothA2DP | allowAirPlay,
            withUI: true)
        .then((_) {
      _setCallbacks();
      _player.setSubscriptionDuration(Duration(milliseconds: 100));
    });
  }

  /// We can play if we have a non-zero duration or we are dynamically
  /// loading tracks via _onLoad.
  Future<bool> get canPlay async {
    return _onLoad != null || (_track != null /* && TODO (_track.length > 0)*/);
  }

  /// detect hot reloads when debugging and stop the player.
  /// If we don't the platform specific code keeps running
  /// and sending methodCalls to a slot that no longer exists.
  @override
  void reassemble() async {
    super.reassemble();
    if (_track != null) {
      if (_playState != _PlayState.stopped) {
        await stop();
      }
      // TODO ! trackRelease(_track);
    }
    //Log.d('Hot reload releasing plugin');
    //_player.release();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playButtonAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  ///
  @override
  Widget build(BuildContext context) {
    registerPlayer(context, this);
    //
    return ChangeNotifierProvider<_SliderPosition>(
        create: (_) => _sliderPosition, child: _buildPlayBar());
  }

  void _setCallbacks() {
    /// TODO
    /// should we chain these events in case the user of our api
    /// also wants to see these events?
    //_player.onStarted = ({wasUser}) => _onStarted();
    //_player.onStopped = ({wasUser}) => _onStopped();

    /// pipe the new sound players stream to our local controller.
    _player.dispositionStream()!.listen(_localController.add);
  }

  void _onStopped() {
    setState(() {
      /// we can get a race condition when we stop the playback
      /// We have disabled the button and called stop.
      /// The OS then sends an onStopped call which tries
      /// to put the state into a stopped state overriding
      /// the disabled state.
      if (_playState != _PlayState.disabled) {
        _playState = _PlayState.stopped;
        playButtonAnimationController!.reverse();
      }
    });
  }

  /// This method is used by the RecorderPlaybackController to attached
  /// the [_localController] to the `SoundRecordUI`'s stream.
  /// This is only done when this player is attached to a
  /// RecorderPlaybackController.
  ///
  /// When recording starts we are attached to the recorderStream.
  /// When recording finishes this method is called with a null and we
  /// revert to the [_player]'s stream.
  ///
  void connectRecorderStream(Stream<PlaybackDisposition>? recorderStream) {
    if (recorderStream != null) {
      recorderStream.listen(_localController.add);
    } else {
      /// revert to piping the player
      _player.dispositionStream()!.listen(_localController.add);
    }
  }

  ///
  @override
  void dispose() {
    print('stopping Player on dispose');
    _stop(supressState: true);
    playButtonAnimationController!.dispose();
    _player.closeAudioSession();
    super.dispose();
  }

  Widget _buildPlayBar() {
    var rows = <Widget>[];
    rows.add(Row(children: [_buildSlider()]));
    if (widget._showTitle && _track != null) rows.add(_buildTitle());

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      _buildDuration(),

      _buildPlayButton(),
      //_buildTitle(),
      /*SizedBox(
        height: 49,
        width: 30,
        child: InkWell(
          onTap: _player.isPaused
              ? resume
              : _player.isPlaying
                  ? pause
                  : null,
          child: Icon(
            _player.isPaused ? Icons.play_arrow : Icons.pause,
            color: _player.isStopped ? _disabledIconColor : Colors.black,
          ),
        ),
      ),*/
      Expanded(
          child: Column(
        children: rows,
        mainAxisAlignment: MainAxisAlignment.center,
      ))
    ]);
  }

  /// Returns the players current state.
  _PlayState get _playState {
    return __playState;
  }

  set _playState(_PlayState state) {
    setState(() => __playState = state);
  }

  /// Controls whether the Play button is enabled or not.
  /// Can not toggle this whilst the player is playing or paused.
  void playbackEnabled({required bool enabled}) {
    assert(
        __playState != _PlayState.playing && __playState != _PlayState.paused);
    setState(() {
      if (enabled == true) {
        __playState = _PlayState.stopped;
        playButtonAnimationController!.reverse();
      } else if (enabled == false) {
        __playState = _PlayState.disabled;
        playButtonAnimationController!.reverse();
      }
    });
  }

  /// Called when the user clicks  the Play/Pause button.
  /// If the audio is paused or stopped the audio will start
  /// playing.
  /// If the audio is playing it will be paused.
  ///
  /// see [play] for the method to programmitcally start
  /// the audio playing.
  void _onPlay(BuildContext localContext) {
    switch (_playState) {
      case _PlayState.stopped:
        play();
        break;

      case _PlayState.playing:
        // stop the player
        _stop();
        break;
      case _PlayState.paused:
        // stop the player
        _stop();

        break;
      case _PlayState.disabled:
        // shouldn't be possible as play button is disabled.
        _stop();
        break;
    }
  }

  /// Call [resume] to resume playing the audio.
  void resume() {
    setState(() {
      _transitioning = true;
      _playState = _PlayState.playing;
    });
    playButtonAnimationController!.forward();

    _player
        .resumePlayer()
        .then((_) => _transitioning = false)
        .catchError((dynamic e) {
      Log.w('Error calling resume ${e.toString()}');
      _playState = _PlayState.stopped;
      playButtonAnimationController!.reverse();
      _player.stopPlayer();
      return false;
    }).whenComplete(() => _transitioning = false);
  }

  /// Call [pause] to pause playing the audio.
  void pause() {
    // pause the player
    setState(() {
      _transitioning = true;
      _playState = _PlayState.paused;
    });
    playButtonAnimationController!.reverse();

    _player
        .pausePlayer()
        .then((_) => _transitioning = false)
        .catchError((dynamic e) {
      Log.w('Error calling pause ${e.toString()}');
      _playState = _PlayState.stopped;
      playButtonAnimationController!.reverse();
      _player.stopPlayer();
      return false;
    }).whenComplete(() => _transitioning = false);
  }

  /// start playback.
  void play() async {
    _transitioning = true;
    _loading = true;
    Log.d('Loading starting');

    Log.d('Calling play');

    if (_track != null && _player.isPlaying) {
      Log.d('play called whilst player running. Stopping Player first.');
      await _stop();
    }

    Future<Track> newTrack;

    if (_onLoad != null) {
      if (_track != null) {
        // TODO trackRelease(_track);
      }

      /// dynamically load the player.
      newTrack = _onLoad!(context);
    } else {
      newTrack = Future.value(_track);
    }

    /// no track then just silently ignore the start action.
    /// This means that _onLoad returned null and the user
    /// can display appropriate errors.
    _track = await newTrack;
    if (_track != null) {
      print("seekpos $seekPos");
      _start();
    } else {
      _loading = false;
      _transitioning = false;
    }
  }

  /// internal start method.
  void _start() async {
    var trck = _track;
    if (trck != null) {
      await _player.startPlayerFromTrack(trck, whenFinished: _onStopped,
          onSkipBackward: () {
        _onPlay(context);
      }, onSkipForward: () {
        _onPlay(context);
      }, onPaused: (_) {
        _onPlay(context);
      }).then((_) {
        _playState = _PlayState.playing;
        playButtonAnimationController!.forward();
      }).catchError((dynamic e) {
        Log.w('Error calling play() ${e.toString()}');
        _playState = _PlayState.stopped;
        playButtonAnimationController!.reverse();

        return null;
      }).whenComplete(() async {
        Log.d(green('Transitioning = false'));
        if (seekPos != null) {
          print("FS --> seeking to  $seekPos");
          await _player.seekToPlayer(seekPos!).whenComplete(() {
            Future.delayed(Duration(milliseconds: 150), () {
              setState(() {
                seekPos = null;
              });
            });
          });
        }
        if (widget._whenPlayStart != null) {
          print("running whenplaystart");
          widget._whenPlayStart!();
        }
        _loading = false;
        _transitioning = false;
      });
    }
  }

  /// Call [stop] to stop the audio playing.
  ///
  Future<void> stop() async {
    await _stop();
  }

  ///
  /// interal stop method.
  ///
  Future<void> _stop({bool supressState = false}) async {
    if (_player.isPlaying || _player.isPaused) {
      print("stopseekpos $seekPos");
      await _player.stopPlayer().then<void>((_) {
        if (_playerSubscription != null) {
          _playerSubscription!.cancel();
          _playerSubscription = null;
        }
        setState(() {});
      });
    }

    // if called via dispose we can't trigger setState.
    if (supressState) {
      __playState = _PlayState.stopped;
      playButtonAnimationController!.reverse();
      __transitioning = false;
      __loading = false;
    } else {
      _playState = _PlayState.stopped;
      playButtonAnimationController!.reverse();
      _transitioning = false;
      _loading = false;
    }

    //_sliderPosition.position = Duration.zero;
  }

  /// put the ui into a 'loading' state which
  /// will start the spinner.
  set _loading(bool value) {
    setState(() => __loading = value);
  }

  /// current loading state.
  bool get _loading {
    return __loading;
  }

  /// When we are moving between states we mark
  /// ourselves as 'transition' to block other
  /// transitions.
  // ignore: avoid_setters_without_getters
  set _transitioning(bool value) {
    Log.d(green('Transitioning = $value'));
    setState(() => __transitioning = value);
  }

  /// Build the play button which includes the loading spinner and pause button
  ///
  Widget _buildPlayButton() {
    Widget? button;

    if (_loading == true) {
      button = Container(
          // margin: const EdgeInsets.only(top: 5.0, bottom: 5),

          /// use a tick builder so we don't show the spinkit unless
          /// at least 100ms has passed. This stops a little flicker
          /// of the spiner caused by the default loading state.
          child:

              // return SpinKitRing(color: Colors.purple, size: 32);
              StreamBuilder<PlaybackDisposition>(
                  stream: _localController.stream,
                  initialData: PlaybackDisposition(
                      duration: Duration.zero, position: Duration.zero),
                  builder: (context, asyncData) {
                    return Container(
                      height: (widget._iconRadius) * 2,
                      width: (widget._iconRadius) * 2,
                      child: Center(
                          child: Container(
                              height: widget._iconRadius,
                              width: widget._iconRadius,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    widget._accentColor ?? Color(0xFFFAF0E6)),
                              ))),
                    );
                  }));
    } else {
      button = _buildPlayButtonIcon(button);
    }
    return _loading == true
        ? button
        : Container(
            child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0),
                child: FutureBuilder<bool>(
                    future: canPlay,
                    builder: (context, asyncData) {
                      var _canPlay = false;
                      if (asyncData.connectionState == ConnectionState.done) {
                        _canPlay = asyncData.data! && !__transitioning;
                      }

                      return Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0)),
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28.0)),
                            radius: widget._iconRadius,
                            child: IconButton(
                                autofocus: true,
                                padding: EdgeInsets.zero,
                                splashRadius: widget._iconSplashRadius,
                                onPressed: _canPlay &&
                                        (_playState == _PlayState.stopped ||
                                            _playState == _PlayState.playing ||
                                            _playState == _PlayState.paused)
                                    ? () async {
                                        return _onPlay(context);
                                      }
                                    : null,
                                icon: button!),
                          ));
                    })));
  }

  Widget _buildPlayButtonIcon(Widget? widget) {
    return AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: playButtonAnimationController!,
        color: _textColor);
  }

  Widget _buildDuration() {
    return StreamBuilder<PlaybackDisposition>(
        stream: _localController.stream,
        initialData: PlaybackDisposition(
            duration: Duration(milliseconds: _rectime!),
            position: Duration(seconds: 0)),
        builder: (context, snapshot) {
          var disposition = snapshot.data!;
          var durationDate =
              Duration(milliseconds: disposition.duration.inMilliseconds);
          var positionDate = seekPos != null
              ? Duration(milliseconds: seekPos!.inMilliseconds)
              : Duration(milliseconds: disposition.position.inMilliseconds);
          var minute = positionDate.inMinutes % 60;
          var second = positionDate.inSeconds % 60;
          var minuteD = durationDate.inMinutes % 60;
          var secondD = durationDate.inSeconds % 60;
          if ((_playState == _PlayState.paused ||
                  _playState == _PlayState.stopped) &&
              seekPos == null) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setState(() {
                seekPos = disposition.position;
              });
              print("pauseseekpos build $seekPos");
            });
          }
          return Text(
              //'${positionDate.minute.toString().padLeft(2, '0')}:${positionDate.second.toString().padLeft(2, '0')} / ${durationDate.minute.toString().padLeft(2, '0')}:${durationDate.second.toString().padLeft(2, '0')}',
              _playState == _PlayState.disabled
                  ? (durationDate.inHours > 0
                      ? '${durationDate.inHours}:${minuteD.toString().padLeft(2, '0')}:${secondD.toString().padLeft(2, '0')}'
                      : '$minuteD:${secondD.toString().padLeft(2, '0')}')
                  : (durationDate.inHours > 0
                      ? '${positionDate.inHours}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}'
                      : '$minute:${second.toString().padLeft(2, '0')}'),
              maxLines: 1,
              overflow: TextOverflow.fade,
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Proxima Nova",
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: _textColor));
        });
  }

  //'${Format.duration(disposition.position, showSuffix: false)}'
  //' / '
  //'${Format.duration(disposition.duration)}',

  /// Specialised method that allows the RecorderPlaybackController
  /// to update our duration as a recording occurs.
  ///
  /// This method should be used for no other purposes.
  ///
  /// During normal playback the [StreamBuilder] used
  /// in [_buildDuration] is responsible for updating the duration.
  // void _updateDuration(Duration duration) {
  //   /// push the update to the next build cycle as this can
  //   /// be called during a build cycle which flutter won't allow.
  //   Future.delayed(Duration.zero,
  //       () => setState(() => _sliderPosition.maxPosition = duration));
  // }

  Widget _buildSlider() {
    return Expanded(
        child: PlaybarSlider(_localController.stream, (position) {
        _sliderPosition.position = position;
      if (_player.isPlaying || _player.isPaused) {
        _player.seekToPlayer(position);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            seekPos = position;
          });
          Log.d("FS --> seek $position");
        });
      }
    }, _sliderThemeData, _rectime, seekPos));
  }

  Widget _buildTitle() {
    var columns = <Widget>[];

    if (_track!.trackTitle != null) {
      columns.add(Text(
        _track!.trackTitle!,
        style: _titleStyle,
      ));
    }
    if (_track!.trackTitle != null && _track!.trackAuthor != null) {
      columns.add(Text(
        ' / ',
        style: _titleStyle,
      ));
    }
    if (_track!.trackAuthor != null) {
      columns.add(Text(
        _track!.trackAuthor!,
        style: _titleStyle,
      ));
    }
    return _track!.trackTitle != null || _track!.trackAuthor != null
        ? Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(children: columns),
          )
        : SizedBox();
  }
}

/// Describes the state of the playbar.
enum _PlayState {
  /// stopped
  stopped,

  ///
  playing,

  ///
  paused,

  ///
  disabled
}

/// GreyedOut optionally grays out the given child widget.
/// [child] the child widget to display
/// If [greyedOut] is true then the child will be grayed out and
/// any touch activity over the child will be discarded.
/// If [greyedOut] is false then the child will displayed as normal.
/// The [opacity] setting controls the visiblity of the child
/// when it is greyed out. A value of 1.0 makes the child fully visible,
/// a value of 0.0 makes the child fully opaque.
/// The default value of [opacity] is 0.3.
class _GrayedOut extends StatelessWidget {
  ///
  final Widget child;

  ///
  final bool grayedOut;

  ///
  final double opacity;

  ///
  _GrayedOut({required this.child, this.grayedOut = true})
      : opacity = grayedOut == true ? 0.3 : 1.0;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: grayedOut, child: Opacity(opacity: opacity, child: child));
  }
}

///
class PlaybarSlider extends StatefulWidget {
  final void Function(Duration position) _seek;

  ///
  final Stream<PlaybackDisposition> stream;

  final SliderThemeData? _sliderThemeData;
  final int? _rectime;
  Duration? seekPos;

  ///
  PlaybarSlider(this.stream, this._seek, this._sliderThemeData, this._rectime,
      this.seekPos);

  @override
  State<StatefulWidget> createState() {
    return _PlaybarSliderState();
  }
}

///
class _PlaybarSliderState extends State<PlaybarSlider> {
  @override
  Widget build(BuildContext context) {
    SliderThemeData? sliderThemeData;
    if (widget._sliderThemeData == null) {
      sliderThemeData = SliderTheme.of(context);
    } else {
      sliderThemeData = widget._sliderThemeData;
    }
    return SliderTheme(
        data: sliderThemeData!.copyWith(
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
          //thumbColor: Colors.amber,
          //inactiveTrackColor: Colors.green,
        ),
        child: StreamBuilder<PlaybackDisposition>(
            stream: widget.stream,
            initialData: PlaybackDisposition(
                duration: Duration(milliseconds: widget._rectime!),
                position: Duration(seconds: 0)),
            builder: (context, snapshot) {
              var disposition = snapshot.data!;

              return Slider(
                max: disposition.duration.inMilliseconds.toDouble(),
                value: widget.seekPos?.inMilliseconds.toDouble() ??
                    disposition.position.inMilliseconds.toDouble(),
                onChanged: (value) =>
                    widget._seek(Duration(milliseconds: value.toInt())),
              );
            }));
  }
}

///
class _SliderPosition extends ChangeNotifier {
  /// The current position of the slider.
  Duration _position = Duration.zero;

  /// The max position of the slider.
  Duration maxPosition = Duration.zero;

  bool _disposed = false;

  ///
  set position(Duration position) {
    _position = position;

    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  ///
  Duration get position {
    return _position;
  }
}
