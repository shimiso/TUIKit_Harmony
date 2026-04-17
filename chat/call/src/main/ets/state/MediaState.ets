@ObservedV2
export class MediaState {
  @Trace isMicrophoneOpen: boolean = true
  @Trace isCameraOpen: boolean = false
  @Trace isFrontCamera: boolean = true
  @Trace isSpeakerphone: boolean = true

  public reset() {
    this.isMicrophoneOpen = true
    this.isCameraOpen = false
    this.isFrontCamera = true
    this.isSpeakerphone = true
  }
}