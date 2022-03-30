/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

import BookAppointmentActivity from './src/ui/main/appointment/BookAppointmentActivity';
import ConfirmBookActivity from './src/ui/main/appointment/ConfirmBookActivity';




import TellUsCondition1Activity from './src/ui/main/appointment/TellUsCondition1Activity';
import TellUsCondition2Activity from './src/ui/main/appointment/TellUsCondition2Activity';
import TellUsCondition3Activity from './src/ui/main/appointment/TellUsCondition3Activity';

import ShopActivity from './src/ui/main/shop/ShopActivity';
import ShopProductDetailActivity from './src/ui/main/shop/ShopProductDetailActivity';
import MyOrdersActivity from './src/ui/main/orders/MyOrdersActivity';
import ShopLikeActivity from './src/ui/main/shop/ShopLikeActivity';
import ProductCartActivity from './src/ui/main/shop/ProductCartActivity';
import CCTShopActivity from './src/ui/main/shop/CCTShopActivity'
import CheckOutActivity from './src/ui/main/shop/CheckOutActivity'
import CouponActivity from './src/ui/main/shop/CouponActivity'
import PaymentMethodActivity from './src/ui/main/shop/PaymentMethodActivity'
import ShopViewAllActivity from './src/ui/main/shop/ShopViewAllActivity'
import ShopOrderSummaryActivity from './src/ui/main/shop/ShopOrderSummaryActivity'





console.ignoredYellowBox = ['Warning: BackAndroid is deprecated. Please use BackHandler instead.','source.uri should not be an empty string','Invalid props.style key'];
console.disableYellowBox = true;
AppRegistry.registerComponent(appName, () => App);
AppRegistry.registerComponent('BookAppointmentActivity', ()=> BookAppointmentActivity);
AppRegistry.registerComponent('TellUsCondition1Activity', ()=> TellUsCondition1Activity);
AppRegistry.registerComponent('TellUsCondition2Activity', ()=> TellUsCondition2Activity);
AppRegistry.registerComponent('TellUsCondition3Activity', ()=> TellUsCondition3Activity);
AppRegistry.registerComponent('ShopActivity', ()=> ShopActivity);
AppRegistry.registerComponent('ShopProductDetailActivity', ()=> ShopProductDetailActivity);
AppRegistry.registerComponent('MyOrdersActivity', ()=> MyOrdersActivity);
AppRegistry.registerComponent('ShopLikeActivity', ()=> ShopLikeActivity);
AppRegistry.registerComponent('ProductCartActivity', ()=> ProductCartActivity);
AppRegistry.registerComponent('CCTShopActivity', ()=> CCTShopActivity);
AppRegistry.registerComponent('CheckOutActivity', ()=> CheckOutActivity);
AppRegistry.registerComponent('CouponActivity', ()=> CouponActivity);
AppRegistry.registerComponent('PaymentMethodActivity', ()=> PaymentMethodActivity);
AppRegistry.registerComponent('ShopViewAllActivity', ()=> ShopViewAllActivity);
AppRegistry.registerComponent('ConfirmBookActivity', ()=> ConfirmBookActivity);
AppRegistry.registerComponent('ShopOrderSummaryActivity', ()=> ShopOrderSummaryActivity);










