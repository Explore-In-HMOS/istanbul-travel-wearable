import media from '@ohos.multimedia.media'
import resourceManager from '@ohos.resourceManager'
import audio from '@ohos.multimedia.audio'

export class AudioManager {
  private static player: media.AVPlayer | null = null

  private static removeListeners(): void {
    const player = AudioManager.player
    if (player) {
      try {
        player.off('stateChange')
        player.off('timeUpdate')
        player.off('audioInterrupt')
        player.off('audioOutputDeviceChangeWithInfo')
      } catch (e) {}
    }
  }

  static async load(
    mgr: resourceManager.ResourceManager,
    audioIndex: number,
    autoPlay: boolean = false
  ): Promise<void> {

    const currentIndex = AppStorage.get<number>('bgPlayerAudioIndex') ?? -1
    if (currentIndex === audioIndex && AudioManager.player) {
      return
    }

      if (AudioManager.player) {
        try {
          AudioManager.removeListeners()
          await AudioManager.player.release()
        } catch (e) {
        }
        AudioManager.player = null
      }

    AppStorage.setOrCreate('bgPlayerAudioIndex', audioIndex)
    AppStorage.setOrCreate('bgPlayerReady', false)
    AppStorage.setOrCreate('bgIsPlaying', false)
    AppStorage.setOrCreate('bgCurrentTime', 0)
    AppStorage.setOrCreate('bgDuration', 0)

    try {
      const player = await media.createAVPlayer()
      AudioManager.player = player

      player.on('stateChange', async (state: string) => {
        const p = AudioManager.player
        if (!p) { return }

        if (state === 'initialized') {
          await p.prepare()
        } else if (state === 'prepared') {
          AppStorage.setOrCreate('bgDuration', p.duration)
          AppStorage.setOrCreate('bgPlayerReady', true)
          if (autoPlay) {
            await p.play()
          }
        } else if (state === 'playing') {
          AppStorage.setOrCreate('bgIsPlaying', true)
        } else if (state === 'paused') {
          AppStorage.setOrCreate('bgIsPlaying', false)
        } else if (state === 'completed') {
          AppStorage.setOrCreate('bgIsPlaying', false)
          AppStorage.setOrCreate('bgCurrentTime', 0)
        }
      })

      player.on('timeUpdate', (time: number) => {
        AppStorage.setOrCreate('bgCurrentTime', time)
      })

      player.on('audioInterrupt', async (interruptEvent: audio.InterruptEvent) => {
        const p = AudioManager.player
        if (!p) { return }
        const hint = interruptEvent.hintType
        if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
          if (
            hint === audio.InterruptHint.INTERRUPT_HINT_PAUSE ||
              hint === audio.InterruptHint.INTERRUPT_HINT_STOP
          ) {
            try { await p.pause() } catch (e) {}
            AppStorage.setOrCreate('bgIsPlaying', false)
          }
        } else {
          if (hint === audio.InterruptHint.INTERRUPT_HINT_RESUME) {
            try { await p.play() } catch (e) {}
            AppStorage.setOrCreate('bgIsPlaying', true)
          }
        }
      })

      player.on('audioOutputDeviceChangeWithInfo', async () => {
        const p = AudioManager.player
        if (!p) { return }
        try { await p.pause() } catch (e) {}
        AppStorage.setOrCreate('bgIsPlaying', false)
      })

      const rawFd = await mgr.getRawFd(`mp3/${audioIndex}.mp3`)
      player.fdSrc = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      }

    } catch (e) {
      console.error('AudioManager init failed', e)
    }
  }

  // Playback control helpers — delegate directly to the shared AVPlayer instance
  static async play(): Promise<void> {
    const player = AudioManager.player
    if (player) { await player.play() }
  }

  static async pause(): Promise<void> {
    const player = AudioManager.player
    if (player) { await player.pause() }
  }

  static setSpeed(speed: media.PlaybackSpeed): void {
    const player = AudioManager.player
    if (player) { player.setSpeed(speed) }
  }

  static async release(): Promise<void> {
    const player = AudioManager.player
    if (player) {
      try {
        AudioManager.removeListeners()
        await player.release()
      } catch (e) {}
      AudioManager.player = null
    }
  }
}