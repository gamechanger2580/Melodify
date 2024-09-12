import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
// import 'package:client/features/home/model/song_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  bool isBright(Color color) {
    return color.computeLuminance() > 0.5;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final backgroundColor = hexToColor(currentSong!.hex_code);
    final userFavorites = ref
        .watch(currentUserNotifierProvider.select((data) => data!.favorites));

    final pullDownArrowColor =
        isBright(backgroundColor) ? Pallete.greyColor : Pallete.whiteColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hexToColor(currentSong.hex_code),
            const Color(0xff121212),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Scaffold(
          backgroundColor: Pallete.transparentColor,
          appBar: AppBar(
            backgroundColor: Pallete.transparentColor,
            leading: Transform.translate(
              offset: const Offset(-15, 0),
              child: InkWell(
                highlightColor: Pallete.transparentColor,
                focusColor: Pallete.transparentColor,
                splashColor: Pallete.transparentColor,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/pull-down-arrow.png',
                    color: pullDownArrowColor,
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Hero(
                    tag: 'music-image',
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(currentSong.thumbnail_url),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.song_name,
                              style: const TextStyle(
                                color: Pallete.whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              currentSong.artist,
                              style: const TextStyle(
                                color: Pallete.subtitleText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(homeViewmodelProvider.notifier)
                                .favSong(
                                  songId: currentSong.id,
                                );
                          },
                          icon: Icon(
                            userFavorites
                                    .where(
                                        (fav) => fav.song_id == currentSong.id)
                                    .toList()
                                    .isNotEmpty
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                          ),
                          color: Pallete.whiteColor,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return StreamBuilder(
                          stream: songNotifier.audioPlayer!.positionStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            }
                            final position = snapshot.data;
                            final duration = songNotifier.audioPlayer!.duration;
                            double sliderValue = 0.0;
                            if (position != null && duration != null) {
                              sliderValue = position.inMilliseconds /
                                  duration.inMilliseconds;
                            }
                            return Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Pallete.whiteColor,
                                    inactiveTrackColor:
                                        Pallete.whiteColor.withOpacity(0.117),
                                    thumbColor: Pallete.whiteColor,
                                    overlayShape:
                                        SliderComponentShape.noOverlay,
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: sliderValue,
                                    min: 0,
                                    max: 1,
                                    onChanged: (val) {
                                      setState(() {
                                        sliderValue = val;
                                      });
                                    },
                                    onChangeEnd: (val) {
                                      songNotifier.seek(val);
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${position?.inMinutes}:${(position?.inSeconds.remainder(60) ?? 0) < 10 ? '0${position?.inSeconds.remainder(60)}' : '${position?.inSeconds.remainder(60)}'}',
                                      style: const TextStyle(
                                        color: Pallete.subtitleText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      '${duration?.inMinutes}:${(duration?.inSeconds.remainder(60) ?? 0) < 10 ? '0${duration?.inSeconds.remainder(60)}' : '${duration?.inSeconds.remainder(60)}'}',
                                      style: const TextStyle(
                                        color: Pallete.subtitleText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/shuffle.png',
                            color: Pallete.whiteColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/previus-song.png',
                            color: Pallete.whiteColor,
                          ),
                        ),
                        IconButton(
                          onPressed: songNotifier.playPause,
                          icon: Icon(
                            songNotifier.isPlaying
                                ? CupertinoIcons.pause_circle_fill
                                : CupertinoIcons.play_circle_fill,
                          ),
                          iconSize: 80,
                          color: Pallete.whiteColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/next-song.png',
                            color: Pallete.whiteColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/repeat.png',
                            color: Pallete.whiteColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/connect-device.png',
                            color: Pallete.whiteColor,
                          ),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/playlist.png',
                            color: Pallete.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
