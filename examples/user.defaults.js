// basic defaults

// yes, we know our rights
user_pref("browser.rights.3.shown", true);

// don't care about the systems "default" browser
user_pref("browser.shell.checkDefaultBrowser", false);

// don't try to update anything
user_pref("browser.search.update", false);
user_pref("app.update.enabled", false);
user_pref("extensions.update.enabled", false);

// don't send statistics
user_pref("toolkit.telemetry.prompted", 2);
user_pref("toolkit.telemetry.rejected", true);
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);

// don't spam us with update informations
user_pref("plugins.update.notifyUser", false);

// don't check for security updates
user_pref("extensions.checkUpdateSecurity", false);
