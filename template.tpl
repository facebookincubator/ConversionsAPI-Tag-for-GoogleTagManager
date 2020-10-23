/*
Copyright (c) Facebook, Inc. and its affiliates.
All rights reserved.

This source code is licensed under the license found in the
LICENSE file in the root directory of this source tree.
*/

___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Facebook Conversions API Tag",
  "brand": {
    "id": "brand_dummy",
    "displayName": "Facebook"
  },
  "description": "A server-side tag template that prepares information from your tagging server to be sent through Facebook’s Conversions API.",
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
    ]
  },
  {
    "type": "TEXT",
    "name": "testEventCode",
    "displayName": "Test Event Code",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_SERVER___

// Sandbox Javascript imports
const getAllEventData = require('getAllEventData');
const sendHttpRequest = require('sendHttpRequest');
const logToConsole = require('logToConsole');
const JSON = require('JSON');

// Constants
const apiEndpoint = 'https://graph.facebook.com';
const apiVersion = 'v8.0';
const partnerAgent = 'gtmss-1.0.0-0.0.1';


// Mapping common Event Model data into Conversions API schema
const eventModel = getAllEventData();
const event = {};
event.event_name = eventModel.event_name;
event.event_time = eventModel.event_time;
event.event_id = eventModel.event_id;
event.event_source_url = eventModel.page_location;

event.user_data = {};
event.user_data.client_ip_address = eventModel.ip_override;
event.user_data.client_user_agent = eventModel.user_agent;
event.user_data.em = eventModel['x-fb-ud-em'];
event.user_data.ph = eventModel['x-fb-ud-ph'];
event.user_data.fn = eventModel['x-fb-ud-fn'];
event.user_data.ln = eventModel['x-fb-ud-ln'];
event.user_data.ge = eventModel['x-fb-ud-ge'];
event.user_data.db = eventModel['x-fb-ud-db'];
event.user_data.ct = eventModel['x-fb-ud-ct'];
event.user_data.st = eventModel['x-fb-ud-st'];
event.user_data.zp = eventModel['x-fb-ud-zp'];
event.user_data.country = eventModel['x-fb-ud-country'];
event.user_data.external_id = eventModel['x-fb-ud-external_id'];
event.user_data.subscription_id = eventModel['x-fb-ud-subscription_id'];
event.user_data.fbp = eventModel['x-fb-ck-fbp'];
event.user_data.fbc = eventModel['x-fb-ck-fbc'];

event.custom_data = {};
event.custom_data.currency = eventModel.currency;
event.custom_data.value = eventModel.value;
event.custom_data.search_string = eventModel.search_term;
event.custom_data.content_category = eventModel['x-fb-cd-content_category'];
event.custom_data.content_ids = eventModel['x-fb-cd-content_ids'];
event.custom_data.content_name = eventModel['x-fb-cd-content_name'];
event.custom_data.content_type = eventModel['x-fb-cd-content_type'];
event.custom_data.contents = eventModel['x-fb-cd-contents'];
event.custom_data.num_items = eventModel['x-fb-cd-num_items'];
event.custom_data.predicted_ltv = eventModel['x-fb-cd-predicted_ltv'];
event.custom_data.status = eventModel['x-fb-cd-status'];
event.custom_data.delivery_category = eventModel['x-fb-cd-delivery_category'];

const eventRequest = {data: [event], partner_agent: partnerAgent};

if(eventModel.test_event_code || data.testEventCode) {
  eventRequest.test_event_code = eventModel.test_event_code ? eventModel.test_event_code : data.testEventCode;
}

// Posting to Conversions API
const routeParams = 'events?access_token=' + data.apiAccessToken;
const graphEndpoint = [apiEndpoint,
                       apiVersion,
                       data.pixelId,
                       routeParams].join('/');

const requestHeaders = {headers: {'content-type': 'application/json'}, method: 'POST'};
sendHttpRequest(
  graphEndpoint,
  (statusCode, headers, response) => {
    logToConsole(JSON.stringify(response));
    if (statusCode >= 200 && statusCode < 300) {
      data.gtmOnSuccess();
      return;
    }
    data.gtmOnFailure();
  },
  requestHeaders,
  JSON.stringify(eventRequest));

logToConsole('Fired Facebook Server Tag');


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
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
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
    assertApi('sendHttpRequest').wasCalledWith(requestEndpoint, actualSuccessCallback, requestHeaderOptions, requestData);
    assertApi('gtmOnSuccess').wasCalled();
setup: |-
  // Arrange
  const JSON = require('JSON');
  const Math = require('Math');
  const logToConsole = require('logToConsole');

  const testConfigurationData = {
    pixelId: '123',
    apiAccessToken: 'abc',
    testEventCode: 'test123',
  };

  const testData = {
    event_name: "Test1",
    event_time: "123456789",
    test_event_code: "test123",
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

  const inputEventModel = {
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
    'user_data': {
      'client_ip_address': testData.user_data.ip_address,
      'client_user_agent': testData.user_data.user_agent,
      'em': testData.user_data.email,
      'ph': testData.user_data.phone_number,
      'fn': testData.user_data.first_name,
      'ln': testData.user_data.last_name,
      'ge': testData.user_data.gender,
      'db': testData.user_data.date_of_brith,
      'ct': testData.user_data.city,
      'st': testData.user_data.state,
      'zp': testData.user_data.zip,
      'country': testData.user_data.country,
      'external_id': testData.user_data.external_id,
      'subscription_id': testData.user_data.subscription_id,
      'fbp': testData.user_data.fbp,
      'fbc': testData.user_data.fbc,
    },
    'custom_data': {
      'currency': testData.custom_data.currency,
      'value': testData.custom_data.value,
      'search_string': testData.custom_data.search_string,
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
  const apiVersion = 'v8.0';
  const partnerAgent = 'gtmss-1.0.0-0.0.1';

  const routeParams = 'events?access_token=' + testConfigurationData.apiAccessToken;
  const requestEndpoint = [apiEndpoint,
                          apiVersion,
                          testConfigurationData.pixelId,
                          routeParams].join('/');

  const requestData = JSON.stringify({data: [expectedEventData], partner_agent: partnerAgent, test_event_code: testData.test_event_code});
  const requestHeaderOptions = {headers: {'content-type': 'application/json'}, method: 'POST'};

  let actualSuccessCallback, httpBody;
  mock('sendHttpRequest', (postUrl, response, options, body) => {
    actualSuccessCallback = response;
    httpBody = body;
    actualSuccessCallback(200, {}, '');
  });


___NOTES___

Created on 8/5/2020, 10:20:28 AM
