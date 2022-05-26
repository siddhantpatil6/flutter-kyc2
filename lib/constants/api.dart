// const String BASE_URL =
//     "http://kyc2-services-dev-1098000510.ap-south-1.elb.amazonaws.com";
// const String DIGILOCKER_URL =
//     "https://subkuauat.angelbroking.com/Digilocker/Kyc";
// const String ESIGN_URL =
//     "https://skycesignuat.angelbroking.com/esignv2/processb2cesign?type=nsdl";
//const String ANALYTIC_URL =
//     "https://abma-analytics-uat-cug.angelbee.in/abma_uat_cug_api";
const String BASE_URL_KEY = "baseUrl";
const String DIGILOCKER_URL_KEY = "digilockerUrl";
const String ESIGN_URL_KEY = "esignUrl";
const String ANALYTIC_URL_KEY = 'analyticUrl';
const String BASE_URL_CDN_KEY = 'cdnUrl';
// const String BASE_URL =
//     "https://services-kyc2-prod.angelbroking.com";
// const String DIGILOCKER_URL =
//     "https://subkua.angelbroking.com/Digilocker/Kyc";
// const String ESIGN_URL =
//     "https://skycesign.angelbroking.com/esignv2/processb2cesign?type=nsdl";
//const String ANALYTIC_URL =
//     'https://angel-clickstream-analytics.angelbee.in/spark_abma_android_api';
const String UPI_URL ='baseUPI';
const String START_API_ENDPOINT = '/v1/kyc/start';
const int RETRY_MILLISECONDS = 3000;
const String HEADER_SOURCE = 'spark';
const String ACCESS_TOKEN =
    'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDYzNzQ1MDQsIm9yaWdfaWF0IjoxNjQ1NzY5NzA0LCJ1c2VyRGF0YSI6eyJjb3VudHJ5X2NvZGUiOiIrOTEiLCJtb2Jfbm8iOiI5NTAwMTk0NDI1IiwidXNlcl9pZCI6Im5hcnV0byIsInNvdXJjZSI6IlNQQVJLIiwiYXBwX2lkIjoiMTI5OCIsIm5hbWUiOiIiLCJlbWFpbCI6IiIsImlkIjoiIiwicm9sZSI6MH19.RD0dhv_GtM8Y1UCgy3a4u0nHhSyeGbhtgbHmth2hLOk';

var appConfig;