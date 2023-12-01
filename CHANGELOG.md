## Unreleased

## Released

0.0.9 (Sept 5, 2023)
* Add secure, HTTP only, 1st party `_gtmeec` cookie to enhance event data. This new cookie can be enabled using 'Enable Event Enhancement' option from the tag.

Toggling this feature “on” will help maximize the performance benefits of the events you currently share with Meta. Using this feature may improve your server events’ Event Match Quality (EMQ) by enabling first party http only secure cookie `_gtmeec` to cache hashed PII that you share using the Meta Pixel through Advanced Matching.

* Add [Data Processing Options](https://developers.facebook.com/docs/marketing-apis/data-processing-options/)
* Fix null value set parameters.
* Correct phone normalisation was also fixed in these changes.
* Invalid template correction and test fixes.

0.0.8 (May 22, 2023)
* Update Conversions API Graph version to v16.0
* Fix syntax error in GTM template for extending meta cookies (fbp/fbc).
* Fix contents array parsing.
* Fix contents array received as [object Object].
* Enable custom parameters.
* Added fb_login_id support.
* Added Meta Logo.

0.0.7 (Feb 27, 2022)
* Update Conversions API Graph version to v14.0

0.0.6 (Jan 24, 2022)
* Upgrading Facebook references to Meta.

0.0.5 (Aug 5, 2021)
* Map gtm.dom event_names to PageView

0.0.4 (Jun 15, 2021)
* Update Conversions API Graph version to v11.0

0.0.3 (Feb 24, 2021)
* Update Conversions API Graph version to v10.0
* Published in [Google Tag Manager Template Gallery](https://tagmanager.google.com/gallery/#/owners/facebookincubator/templates/ConversionsAPI-Tag-for-GoogleTagManager)

0.0.2 (Dec 22, 2020)
* Update Conversions API Graph version to v9.0

0.0.1 (Oct 2, 2020)
* Tag for deploying on Google Tag Manager's server-side to send Conversions API events.
