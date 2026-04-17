export function formatSecondsTo00(timeSeconds: number) {
  let second = Math.floor(timeSeconds % 60)
  let minuteTemp = Math.floor(timeSeconds / 60)
  if (minuteTemp > 0) {
    let minute = Math.floor(minuteTemp % 60)
    let hour = Math.floor(minuteTemp / 60)
    if (hour > 0) {
      return (hour >= 10 ? (hour + "") : ("0" + hour)) + ":" + (minute >= 10 ? (minute + "") : ("0" + minute)) + ":"
        + (second >= 10 ? (second + "") : ("0" + second));
    }
    return (minute >= 10 ? (minute + "") : ("0" + minute)) + ":" + (second >= 10 ? (second + "") : ("0" + second));
  }
  return "00:" + (second >= 10 ? second + "" : "0" + second);
}
