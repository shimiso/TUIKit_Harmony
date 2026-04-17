import { preferences } from '@kit.ArkData';
import { HashMap } from '@kit.ArkTS';

export class Preference {
  private static preferenceMap: HashMap<String, Preference> = new HashMap();
  private dataPreferences: preferences.Preferences | null = null;

  constructor(preferenceName: string) {
    let options: preferences.Options = { name: preferenceName };
    if (this.dataPreferences == null) {
      this.dataPreferences = preferences.getPreferencesSync(getContext(), options);
    }
  }

  public static getInstance(preferenceName: string): Preference {
    if (preferenceName.trim().length == 0) {
      preferenceName = "callkit"
    }

    let preference: Preference = Preference.preferenceMap.get(preferenceName)
    if (preference == null) {
      preference = new Preference(preferenceName)
      Preference.preferenceMap.set(preferenceName, preference)
    }
    return preference
  }

  public has(key: string): boolean {
    return this.dataPreferences != null ? this.dataPreferences.hasSync(key) : false
  }

  public putString(key: string, value: string) {
    this.dataPreferences?.putSync(key, value)
  }

  public getString(key: string, defValue: string): string {
    return (this.dataPreferences != null ? this.dataPreferences.getSync(key, defValue) : defValue) as string
  }

  public putBoolean(key: string, value: boolean) {
    this.dataPreferences?.putSync(key, value)
  }

  public getBoolean(key: string, defValue: boolean): boolean {
    return (this.dataPreferences != null ? this.dataPreferences.getSync(key, defValue) : defValue) as boolean
  }
}