class Logger {
  constructor() {
  }

  info(tag: string, message: string, ...args: object[]): void {
    console.info(TAG + tag + ": " + message, args)
  }

  log(tag: string, message: string, ...args: object[]): void {
    console.log(TAG + tag + ": " + message, args)
  }

  warn(tag: string, message: string, ...args: object[]): void {
    console.warn(TAG + tag + ": " + message, args)
  }

  error(tag: string, message: string, ...args: object[]): void {
    console.error(TAG + tag + ": " + message, args)
  }
}

const TAG: string = "[CallKit] "

export default new Logger()