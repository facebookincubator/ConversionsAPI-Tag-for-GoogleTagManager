___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Conversions API Tag",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "A server-side tag template that prepares information from your tagging server to be sent through Conversions API.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "pixelId",
    "displayName": "Pixel ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "apiAccessToken",
    "displayName": "API Access Token",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "To use the Conversions API, you need an access token. See \u003ca href\u003d\"https://developers.facebook.com/docs/marketing-api/conversions-api/get-started#access-token\"\u003ehere\u003c/a\u003e for generating an access token."
  },
  {
    "type": "TEXT",
    "name": "testEventCode",
    "displayName": "Test Event Code",
    "simpleValueType": true,
    "help": "Code used to verify that your server events are received correctly by Conversions API. Use this code to test your server events in the Test Events feature in Events Manager. See \u003ca href\u003d\"https://developers.facebook.com/docs/marketing-api/conversions-api/using-the-api#testEvents\"\u003e Test Events Tool\u003c/a\u003e for an example."
  },
  {
    "type": "SELECT",
    "name": "actionSource",
    "displayName": "Action Source",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "website",
        "displayValue": "Website"
      },
      {
        "value": "email",
        "displayValue": "Email"
      },
      {
        "value": "app",
        "displayValue": "App"
      },
      {
        "value": "phone_call",
        "displayValue": "Phone Call"
      },
      {
        "value": "chat",
        "displayValue": "Chat"
      },
      {
        "value": "physical_store",
        "displayValue": "Physical Store"
      },
      {
        "value": "system_generated",
        "displayValue": "System Generated"
      },
      {
        "value": "other",
        "displayValue": "Other"
      }
    ],
    "simpleValueType": true,
    "help": "This field allows you to specify where your conversions occurred. Knowing where your events took place helps ensure your ads go to the right people. See \u003ca href\u003d\"https://developers.facebook.com/docs/marketing-api/conversions-api/parameters/server-event#action-source\"\u003ehere\u003c/a\u003e for more information."
  }
]


___SANDBOXED_JS_FOR_SERVER___

// Sandbox Javascript imports
const getAllEventData = require('getAllEventData');
const getType = require('getType');
const sendHttpRequest = require('sendHttpRequest');
const JSON = require('JSON');
const Math = require('Math');
const getTimestampMillis = require('getTimestampMillis');
const sha256Sync = require('sha256Sync');
const getCookieValues = require('getCookieValues');

// Constants
const API_ENDPOINT = 'https://graph.facebook.com';
const API_VERSION = 'v12.0';
const PARTNER_AGENT = 'gtmss-1.0.0-0.0.5';
const GTM_EVENT_MAPPINGS = {
  "add_payment_info": "AddPaymentInfo",
  "add_to_cart": "AddToCart",
  "add_to_wishlist": "AddToWishlist",
  "gtm.dom": "PageView",
  "page_view": "PageView",
  "purchase": "Purchase",
  "search": "Search",
  "begin_checkout": "InitiateCheckout",
  "generate_lead": "Lead",
  "view_item": "ViewContent",
  "sign_up": "CompleteRegistration"
};

function isAlreadyHashed(input){
  return input && (input.match('^[A-Fa-f0-9]{64}$') != null);
}


function hashFunction(input){
  const type = getType(input);

  if(type == 'undefined' || input == 'undefined') {
    return undefined;
  }

  if(input == null || isAlreadyHashed(input)){
    return input;
  }

  return sha256Sync(input.trim().toLowerCase(), {outputEncoding: 'hex'});
}

function getContentFromItems(items) {
    return items.map(item => {
        return {
            "id": item.item_id,
            "title": item.item_name,
            "item_price": item.price,
            "brand": item.item_brand,
            "quantity": item.quantity,
            "category": item.item_category,
        };
    });
}

function getFacebookEventName(gtmEventName) {
  return GTM_EVENT_MAPPINGS[gtmEventName] || gtmEventName;
}



const eventModel = getAllEventData();
const event = {};
event.event_name = getFacebookEventName(eventModel.event_name);
event.event_time = eventModel.event_time || (Math.round(getTimestampMillis() / 1000));
event.event_id = eventModel.event_id;
event.event_source_url = eventModel.page_location;
if(eventModel.action_source || data.actionSource) {
  event.action_source = eventModel.action_source ? eventModel.action_source : data.actionSource;
}

event.user_data = {};
// Default Tag Parameters
event.user_data.client_ip_address = eventModel.ip_override;
event.user_data.client_user_agent = eventModel.user_agent;


// Commmon Event Schema Parameters
event.user_data.em = eventModel['x-fb-ud-em'] ||
                        (eventModel.user_data != null ? hashFunction(eventModel.user_data.email_address) : null);
event.user_data.ph = eventModel['x-fb-ud-ph'] ||
                        (eventModel.user_data != null ? hashFunction(eventModel.user_data.phone_number) : null);

const addressData = (eventModel.user_data != null && eventModel.user_data.address != null) ? eventModel.user_data.address : {};
event.user_data.fn = eventModel['x-fb-ud-fn'] || hashFunction(addressData.first_name);
event.user_data.ln = eventModel['x-fb-ud-ln'] || hashFunction(addressData.last_name);
event.user_data.ct = eventModel['x-fb-ud-ct'] || hashFunction(addressData.city);
event.user_data.st = eventModel['x-fb-ud-st'] || hashFunction(addressData.region);
event.user_data.zp = eventModel['x-fb-ud-zp'] || hashFunction(addressData.postal_code);
event.user_data.country = eventModel['x-fb-ud-country'] || hashFunction(addressData.country);

// Conversions API Specific Parameters
event.user_data.ge = eventModel['x-fb-ud-ge'];
event.user_data.db = eventModel['x-fb-ud-db'];
event.user_data.external_id = eventModel['x-fb-ud-external_id'];
event.user_data.subscription_id = eventModel['x-fb-ud-subscription_id'];
event.user_data.fbp = eventModel['x-fb-ck-fbp'] || getCookieValues('_fbp', true)[0];
event.user_data.fbc = eventModel['x-fb-ck-fbc'] || getCookieValues('_fbc', true)[0];

event.custom_data = {};
event.custom_data.currency = eventModel.currency;
event.custom_data.value = eventModel.value;
event.custom_data.search_string = eventModel.search_term;
event.custom_data.order_id = eventModel.transaction_id;
event.custom_data.content_category = eventModel['x-fb-cd-content_category'];
event.custom_data.content_ids = eventModel['x-fb-cd-content_ids'];
event.custom_data.content_name = eventModel['x-fb-cd-content_name'];
event.custom_data.content_type = eventModel['x-fb-cd-content_type'];
event.custom_data.contents = eventModel['x-fb-cd-contents'] ||
                                  (eventModel.items != null ? getContentFromItems(eventModel.items) : null);
event.custom_data.num_items = eventModel['x-fb-cd-num_items'];
event.custom_data.predicted_ltv = eventModel['x-fb-cd-predicted_ltv'];
event.custom_data.status = eventModel['x-fb-cd-status'];
event.custom_data.delivery_category = eventModel['x-fb-cd-delivery_category'];

const eventRequest = {data: [event], partner_agent: PARTNER_AGENT};

if(eventModel.test_event_code || data.testEventCode) {
  eventRequest.test_event_code = eventModel.test_event_code ? eventModel.test_event_code : data.testEventCode;
}

// Posting to Conversions API
const routeParams = 'events?access_token=' + data.apiAccessToken;
const graphEndpoint = [API_ENDPOINT,
                       API_VERSION,
                       data.pixelId,
                       routeParams].join('/');

const requestHeaders = {headers: {'content-type': 'application/json'}, method: 'POST'};
sendHttpRequest(
  graphEndpoint,
  (statusCode, headers, response) => {
    if (statusCode >= 200 && statusCode < 300) {
      data.gtmOnSuccess();
      return;
    }
    data.gtmOnFailure();
  },
  requestHeaders,
  JSON.stringify(eventRequest));

___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://graph.facebook.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "_fbp"
              },
              {
                "type": 1,
                "string": "_fbc"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: on EventModel model data tag triggers to send to Conversions API
  code: |-
    // Act
    runCode(testConfigurationData);

    //Assert
    assertApi('sendHttpRequest').wasCalledWith(requestEndpoint, actualSuccessCallback, requestHeaderOptions, JSON.stringify(requestData));
    assertApi('gtmOnSuccess').wasCalled();
- name: on Event with common event schema triggers tag to send to Conversions API
  code: |-
    const preTagFireEventTime = Math.round(getTimestampMillis() / 1000);
    const common_event_schema = {
        event_name: testData.event_name,
        client_id: 'client123',
        ip_override: testData.ip_address,
        user_agent: testData.user_agent,
      };
    mock('getAllEventData', () => {
      return common_event_schema;
    });

    // Act
    runCode(testConfigurationData);

    //Assert
    const actualTagFireEventTime = JSON.parse(httpBody).data[0].event_time;
    assertThat(actualTagFireEventTime-preTagFireEventTime).isLessThan(1);
    assertApi('gtmOnSuccess').wasCalled();
- name: on sending action source from Client, Tag overrides the preset configuration
  code: |-
    // Act
    mock('getAllEventData', () => {
      inputEventModel.action_source = testData.action_source;
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].action_source).isEqualTo(inputEventModel.action_source);
- name: on receiving event, if GTM Standard Event then Tag converts to corresponding
    Conversions API Event, passes through as-is if otherwise
  code: |-
    // Act
    mock('getAllEventData', () => {
      inputEventModel.event_name = 'add_to_wishlist';
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].event_name).isEqualTo('AddToWishlist');


    // Act
    mock('getAllEventData', () => {
      inputEventModel.event_name = 'custom_event';
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].event_name).isEqualTo('custom_event');

    // Act
    mock('getAllEventData', () => {
      inputEventModel.event_name = 'generate_lead';
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].event_name).isEqualTo('Lead');
- name: On receiving event, hashes the the user_data fields if they are not already hashed
  code: |-
    // Un-hashed raw email_address from Common Event Schema is hashed before posted to Conversions API.

    // Act
    mock('getAllEventData', () => {
      inputEventModel['x-fb-ud-em'] = null;
      inputEventModel['x-fb-ud-ph'] = null;
      inputEventModel['x-fb-ud-fn'] = null;
      inputEventModel['x-fb-ud-ln'] = null;
      inputEventModel['x-fb-ud-ct'] = null;
      inputEventModel['x-fb-ud-st'] = null;
      inputEventModel['x-fb-ud-zp'] = null;
      inputEventModel['x-fb-ud-country'] = null;
      inputEventModel.user_data = {};
      inputEventModel.user_data.email_address = 'foo@bar.com';
      inputEventModel.user_data.phone_number = '1234567890';
      inputEventModel.user_data.address = {};
      inputEventModel.user_data.address.first_name = 'Foo';
      inputEventModel.user_data.address.last_name = 'Bar';
      inputEventModel.user_data.address.city = 'Menlo Park';
      inputEventModel.user_data.address.region = 'ca';
      inputEventModel.user_data.address.postal_code = '12345';
      inputEventModel.user_data.address.country = 'usa';
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].user_data.em).isEqualTo(hashFunction('foo@bar.com'));
    assertThat(JSON.parse(httpBody).data[0].user_data.ph).isEqualTo(hashFunction('1234567890'));
    assertThat(JSON.parse(httpBody).data[0].user_data.fn).isEqualTo(hashFunction('Foo'));
    assertThat(JSON.parse(httpBody).data[0].user_data.ln).isEqualTo(hashFunction('Bar'));
    assertThat(JSON.parse(httpBody).data[0].user_data.ct).isEqualTo(hashFunction('Menlo Park'));
    assertThat(JSON.parse(httpBody).data[0].user_data.st).isEqualTo(hashFunction('ca'));
    assertThat(JSON.parse(httpBody).data[0].user_data.zp).isEqualTo(hashFunction('12345'));
    assertThat(JSON.parse(httpBody).data[0].user_data.country).isEqualTo(hashFunction('usa'));

    // Un-hashed raw email_address in mixed-case is converted to lowercase, hashed and posted to Conversions API.

    // Act
    mock('getAllEventData', () => {
      inputEventModel.user_data.email_address = 'FOO@BAR.com';
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].user_data.em).isEqualTo(hashFunction('foo@bar.com'));


    // Already sha256(email_address) field from GA4 schema, is unchanged, is posted as-is to Conversions API.

    // Act
    mock('getAllEventData', () => {
      inputEventModel.user_data.email_address = hashFunction('foo@bar.com');
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].user_data.em).isEqualTo(hashFunction('foo@bar.com'));

    // Already null email field from GA4 schema, is sent as null to Conversions API.

    // Act
    mock('getAllEventData', () => {
      inputEventModel.user_data.email_address = null;
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].user_data.em).isEqualTo(null);
- name: On receiving event with fbp/fbc cookies, it is sent to Conversions API
  code: |-
    // Act
    mock('getAllEventData', () => {
      inputEventModel['x-fb-ck-fbp'] = null;
      inputEventModel['x-fb-ck-fbc'] = null;
      return inputEventModel;
    });

    mock('getCookieValues', (cookieName) => {
      if(cookieName === '_fbp') return ['fbp_cookie'];
      if(cookieName === '_fbc') return ['fbc_cookie'];
    });

    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].user_data.fbp).isEqualTo('fbp_cookie');
    assertThat(JSON.parse(httpBody).data[0].user_data.fbc).isEqualTo('fbc_cookie');
- name: On receiving GA4 event, with the items info, tag parses them into Conversions API schema
  code: |-
    // Act
    let items = [
        {
          item_id: '1',
          item_name: 'item_1',
          quantity: 5,
          price: 123.45,
          item_category: 'cat_1',
          item_brand: 'brand_1',
        },
        {
        item_id: '2',
        item_name: 'item_2',
        quantity: 10,
        price: 123.45,
        item_category: 'cat_2',
        item_brand: 'brand_2',
        }
      ];
    mock('getAllEventData', () => {
      inputEventModel['x-fb-cd-contents'] = null;
      inputEventModel.items = items;
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    let actual_contents = JSON.parse(httpBody).data[0].custom_data.contents;
    assertThat(JSON.parse(httpBody).data[0].custom_data.contents.length).isEqualTo(items.length);
    for( var i = 0; i < items.length; i++) {
      assertThat(actual_contents[i].id).isEqualTo(items[i].item_id);
      assertThat(actual_contents[i].item_price).isEqualTo(items[i].price);
      assertThat(actual_contents[i].brand).isEqualTo(items[i].item_brand);
      assertThat(actual_contents[i].quantity).isEqualTo(items[i].quantity);
      assertThat(actual_contents[i].category).isEqualTo(items[i].item_category);
    }

    // Act
    mock('getAllEventData', () => {
      inputEventModel.items = null;
      return inputEventModel;
    });
    runCode(testConfigurationData);

    //Assert
    assertThat(JSON.parse(httpBody).data[0].custom_data.contents).isEqualTo(null);
- name: When address is missing it skips parsing the nested fields
  code: |
    mock('getAllEventData', () => {
      inputEventModel['x-fb-ud-em'] = null;
      inputEventModel['x-fb-ud-ph'] = null;
      inputEventModel['x-fb-ud-fn'] = null;
      inputEventModel['x-fb-ud-ln'] = null;
      inputEventModel['x-fb-ud-ct'] = null;
      inputEventModel['x-fb-ud-st'] = null;
      inputEventModel['x-fb-ud-zp'] = null;
      inputEventModel['x-fb-ud-country'] = null;
      inputEventModel.user_data = {};
      inputEventModel.user_data.email_address = 'foo@bar.com';
      inputEventModel.user_data.phone_number = '1234567890';
      return inputEventModel;
    });

    runCode(testConfigurationData);

    assertThat(JSON.parse(httpBody).data[0].user_data.em).isEqualTo(hashFunction('foo@bar.com'));
    assertThat(JSON.parse(httpBody).data[0].user_data.ph).isEqualTo(hashFunction('1234567890'));
    assertThat(JSON.parse(httpBody).data[0].user_data.fn).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.ln).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.ct).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.st).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.zp).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.country).isUndefined();
- name: When parameters are undefined skip parsing
  code: |
    mock('getAllEventData', () => {
      inputEventModel['x-fb-ud-em'] = null;
      inputEventModel['x-fb-ud-ph'] = null;
      inputEventModel['x-fb-ud-fn'] = null;
      inputEventModel['x-fb-ud-ln'] = null;
      inputEventModel['x-fb-ud-ct'] = null;
      inputEventModel['x-fb-ud-st'] = null;
      inputEventModel['x-fb-ud-zp'] = null;
      inputEventModel['x-fb-ud-country'] = null;
      inputEventModel.user_data = {};
      inputEventModel.user_data.email_address = undefined;
      inputEventModel.user_data.phone_number = '1234567890';
      inputEventModel.user_data.address = {};
      inputEventModel.user_data.address.first_name = 'John';
      inputEventModel.user_data.address.last_name = undefined;
      inputEventModel.user_data.address.city = 'menlopark';
      inputEventModel.user_data.address.region = 'ca';
      inputEventModel.user_data.address.postal_code = '94025';
      inputEventModel.user_data.address.country = 'usa';
      return inputEventModel;
    });

    runCode(testConfigurationData);

    assertThat(JSON.parse(httpBody).data[0].user_data.em).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.ph).isEqualTo(hashFunction('1234567890'));
    assertThat(JSON.parse(httpBody).data[0].user_data.fn).isEqualTo(hashFunction('John'));
    assertThat(JSON.parse(httpBody).data[0].user_data.ln).isUndefined();
    assertThat(JSON.parse(httpBody).data[0].user_data.ct).isEqualTo(hashFunction('menlopark'));
    assertThat(JSON.parse(httpBody).data[0].user_data.st).isEqualTo(hashFunction('ca'));
    assertThat(JSON.parse(httpBody).data[0].user_data.zp).isEqualTo(hashFunction('94025'));
    assertThat(JSON.parse(httpBody).data[0].user_data.country).isEqualTo(hashFunction('usa'));
setup: |-
  // Arrange
  const JSON = require('JSON');
  const Math = require('Math');
  const getTimestampMillis = require('getTimestampMillis');
  const sha256Sync = require('sha256Sync');

  // helper methods
  function hashFunction(input) {
    return sha256Sync(input.trim().toLowerCase(), {outputEncoding: 'hex'});
  }

  const testConfigurationData = {
    pixelId: '123',
    apiAccessToken: 'abc',
    testEventCode: 'test123',
    actionSource: 'source123'
  };

  const testData = {
    event_name: "Test1",
    event_time: "123456789",
    test_event_code: "test123",
    action_source: 'website',
    user_data: {
      ip_address: '1.2.3.4',
      user_agent: 'Test_UA',
      email: 'test@example.com',
      phone_number: '123456789',
      first_name: 'foo',
      last_name: 'bar',
      gender: 'm',
      date_of_brith: '19910526',
      city: 'menlopark',
      state: 'ca',
      country: 'us',
      zip: '12345',
      external_id: 'user123',
      subscription_id: 'abc123',
      fbp: 'test_browser_id',
      fbc: 'test_click_id',
    },
    custom_data: {
      currency: 'USD',
      value: '123',
      search_string: 'query123',
      transaction_id: 'order_123',
      content_category: 'testCategory',
      content_ids: ['123', '456'],
      content_name: 'Foo',
      content_type: 'product',
      contents:  [{'id': '123', 'quantity': 2}, {'id': '456', 'quantity': 2}],
      num_items: '4',
      predicted_ltv: '10000',
      delivery_category: 'home_delivery',
      status: 'subscribed',
    }
  };

  let inputEventModel = {
    'event_name': testData.event_name,
    'event_time': testData.event_time,
    'ip_override': testData.user_data.ip_address,
    'user_agent': testData.user_data.user_agent,
    'test_event_code': testData.test_event_code,
    'x-fb-ud-em': testData.user_data.email,
    'x-fb-ud-ph': testData.user_data.phone_number,
    'x-fb-ud-fn': testData.user_data.first_name,
    'x-fb-ud-ln': testData.user_data.last_name,
    'x-fb-ud-ge': testData.user_data.gender,
    'x-fb-ud-db': testData.user_data.date_of_brith,
    'x-fb-ud-ct': testData.user_data.city,
    'x-fb-ud-st': testData.user_data.state,
    'x-fb-ud-zp': testData.user_data.zip,
    'x-fb-ud-country': testData.user_data.country,
    'x-fb-ud-external_id': testData.user_data.external_id,
    'x-fb-ud-subscription_id': testData.user_data.subscription_id,
    'x-fb-ck-fbp': testData.user_data.fbp,
    'x-fb-ck-fbc': testData.user_data.fbc,
    'currency': testData.custom_data.currency,
    'value': testData.custom_data.value,
    'search_term': testData.custom_data.search_string,
    'transaction_id': testData.custom_data.transaction_id,
    'x-fb-cd-status': testData.custom_data.status,
    'x-fb-cd-content_category': testData.custom_data.content_category,
    'x-fb-cd-content_name': testData.custom_data.content_name,
    'x-fb-cd-content_type': testData.custom_data.content_type,
    'x-fb-cd-contents': testData.custom_data.contents,
    'x-fb-cd-num_items': testData.custom_data.num_items,
    'x-fb-cd-predicted_ltv': testData.custom_data.predicted_ltv,
    'x-fb-cd-delivery_category': testData.custom_data.delivery_category,
  };

  const expectedEventData = {
  'event_name': testData.event_name,
  'event_time': testData.event_time,
  'action_source': testConfigurationData.actionSource,
  'user_data': {
    'client_ip_address': testData.user_data.ip_address,
    'client_user_agent': testData.user_data.user_agent,
    'em': testData.user_data.email,
    'ph': testData.user_data.phone_number,
    'fn': testData.user_data.first_name,
    'ln': testData.user_data.last_name,
    'ct': testData.user_data.city,
    'st': testData.user_data.state,
    'zp': testData.user_data.zip,
    'country': testData.user_data.country,
    'ge': testData.user_data.gender,
    'db': testData.user_data.date_of_brith,
    'external_id': testData.user_data.external_id,
    'subscription_id': testData.user_data.subscription_id,
    'fbp': testData.user_data.fbp,
    'fbc': testData.user_data.fbc,
  },
    'custom_data': {
      'currency': testData.custom_data.currency,
      'value': testData.custom_data.value,
      'search_string': testData.custom_data.search_string,
      'order_id': testData.custom_data.transaction_id,
      'content_category': testData.custom_data.content_category,
      'content_name': testData.custom_data.content_name,
      'content_type': testData.custom_data.content_type,
      'contents': testData.custom_data.contents,
      'num_items': testData.custom_data.num_items,
      'predicted_ltv': testData.custom_data.predicted_ltv,
      'status': testData.custom_data.status,
      'delivery_category': testData.custom_data.delivery_category,
    }
  };

  mock('getAllEventData', () => {
    return inputEventModel;
  });

  const apiEndpoint = 'https://graph.facebook.com';
  const apiVersion = 'v12.0';
  const partnerAgent = 'gtmss-1.0.0-0.0.4';

  const routeParams = 'events?access_token=' + testConfigurationData.apiAccessToken;
  const requestEndpoint = [apiEndpoint,
                          apiVersion,
                          testConfigurationData.pixelId,
                          routeParams].join('/');

  let requestData = {
                      data: [expectedEventData],
                      partner_agent: partnerAgent,
                      test_event_code: testData.test_event_code
                     };
  const requestHeaderOptions = {headers: {'content-type': 'application/json'}, method: 'POST'};

  let actualSuccessCallback, httpBody;
  mock('sendHttpRequest', (postUrl, response, options, body) => {
    actualSuccessCallback = response;
    httpBody = body;
    actualSuccessCallback(200, {}, '');
  });


___NOTES___

Created on 8/5/2020, 10:20:28 AM
