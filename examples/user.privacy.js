// privacy settings

// don't execute javascript
user_pref("javascript.enabled", false);

// don't request something upon start
user_pref("browser.startup.homepage", "about:blank");

// don't query search engine
user_pref("browser.search.suggest.enabled", false);
user_pref("network.prefetch-next", false);

// no..
user_pref("geo.enabled", false);

// maybe someone really cares..
user_pref("privacy.donottrackheader.enabled", true);

// don't save passwords or formulars
user_pref("signon.rememberSignons", false);
user_pref("signon.prefillForms", false);

// set up duckduckgo as search engine
user_pref("browser.search.defaultenginename", "DuckDuckGo");
user_pref("browser.search.order.1", "DuckDuckGo");

// no google lookups
user_pref("browser.safebrowsing.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.remoteLookups", false);
