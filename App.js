/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow strict-local
 */

import React from 'react';
import {
  SafeAreaView,
  StyleSheet,
  ScrollView,
  View,
  Text,
  StatusBar,
} from 'react-native';

import {
  Header,
  LearnMoreLinks,
  Colors,
  DebugInstructions,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';


import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';


//login
import FristActivity from './src/ui/login/FristActivity';
import OnboardingActivity from './src/ui/login/OnboardingActivity';
import LoginActivity from './src/ui/login/LoginActivity';
import SignUp1Activity from './src/ui/login/SignUp1Activity';
import SignUp2Activity from './src/ui/login/SignUp2Activity';
import SignUp2_1Activity from './src/ui/login/SignUp2_1Activity';
import SignUp3Activity from './src/ui/login/SignUp3Activity';
import SignUp4Activity from './src/ui/login/SignUp4Activity';
import SignUp5Activity from './src/ui/login/SignUp5Activity';
import WelcomeBackActivity from './src/ui/login/WelcomeBackActivity';
import SignIn1Activity from './src/ui/login/SignIn1Activity';
import SignIn2Activity from './src/ui/login/SignIn2Activity';
import ResetPasswordActivity from './src/ui/login/ResetPasswordActivity';
import MainActivity from './src/ui/main/MainActivity';



//appointment
import BookAppointmentActivity from './src/ui/main/appointment/BookAppointmentActivity';
import ConfirmBookActivity from './src/ui/main/appointment/ConfirmBookActivity';
import BookDetailsActivity from './src/ui/main/appointment/BookDetailsActivity';
import TellUsCondition1Activity from './src/ui/main/appointment/TellUsCondition1Activity';
import TellUsCondition2Activity from './src/ui/main/appointment/TellUsCondition2Activity';
import TellUsCondition3Activity from './src/ui/main/appointment/TellUsCondition3Activity';
import ScanQRCodeActivity from './src/ui/main/ScanQRCodeActivity';
import CheckInConfirmBookActivity from './src/ui/main/appointment/CheckInConfirmBookActivity';
import TreatmentDevlarationActivity from './src/ui/main/appointment/TreatmentDevlarationActivity';
import PreConceptionDevlarationActivity from './src/ui/main/appointment/PreConceptionDevlarationActivity';
import PostPartumDevlarationActivity from './src/ui/main/appointment/PostPartumDevlarationActivity';
import SelectedBookServicesActivity from './src/ui/main/appointment/SelectedBookServicesActivity';
import ToadyBookServicesActivity from './src/ui/main/appointment/ToadyBookServicesActivity';
import BookCompletedDetailsActivity from './src/ui/main/appointment/BookCompletedDetailsActivity';







//shop
import ShopActivity from './src/ui/main/shop/ShopActivity';
import CCTShopActivity from './src/ui/main/shop/CCTShopActivity';
import ShopProductDetailActivity from './src/ui/main/shop/ShopProductDetailActivity';
import ProductCartActivity from './src/ui/main/shop/ProductCartActivity';
import CheckOutActivity from './src/ui/main/shop/CheckOutActivity';
import CouponActivity from './src/ui/main/shop/CouponActivity';
import PaymentMethodActivity from './src/ui/main/shop/PaymentMethodActivity';
import ShopLikeActivity from './src/ui/main/shop/ShopLikeActivity';
import ShopViewAllActivity from './src/ui/main/shop/ShopViewAllActivity';
import ShopOrderSummaryActivity from './src/ui/main/shop/ShopOrderSummaryActivity';



//wallet
import MyWalletActivity from './src/ui/main/mywallet/MyWalletActivity';
import TransactionsDetailActivity from './src/ui/main/mywallet/TransactionsDetailActivity';
import VoucherDetailActivity from './src/ui/main/mywallet/VoucherDetailActivity';
import TopUpActivity from './src/ui/main/mywallet/TopUpActivity';
import TopUpMethodActivity from './src/ui/main/mywallet/TopUpMethodActivity';
import CardDetailsActivity from './src/ui/main/mywallet/CardDetailsActivity';
import TierPrivilegesActivity from './src/ui/main/mywallet/TierPrivilegesActivity';
import AddCardUserActivity from './src/ui/main/mywallet/AddCardUserActivity';
import UserCardDetailsActivity from './src/ui/main/mywallet/UserCardDetailsActivity';



//refer friend
import ReferToAFriendActivity from './src/ui/main/referfriend/ReferToAFriendActivity';


//service
import OurServiceActivity from './src/ui/main/service/OurServiceActivity';


//Conditions We Treat
import ConditionsWeTreatActivity from './src/ui/main/comditionswetreat/ConditionsWeTreatActivity';



//Edit Profile
import EditProfileActivity from './src/ui/main/editprofile/EditProfileActivity';




//Orders
import MyOrdersActivity from './src/ui/main/orders/MyOrdersActivity';
import OrderDetailsActivity from './src/ui/main/orders/OrderDetailsActivity';


//Frequently Asked Questions
import FrequentlyAskedQuestionsActivity from './src/ui/main/frequentlyaskedquestions/FrequentlyAskedQuestionsActivity';


//Setting
import SettingActivity from './src/ui/main/setting/SettingActivity';



//Account Management
import AccountManagementActivity from './src/ui/main/accountmanagement/AccountManagementActivity';
import EditLoginTypeActivity from './src/ui/main/accountmanagement/EditLoginTypeActivity';
import ChangePasswordActivity from './src/ui/main/accountmanagement/ChangePasswordActivity';


//ContactUs
import ContactUsActivity from './src/ui/main/contactus/ContactUsActivity';



const App: () => React$Node = () => {

  const Stack = createStackNavigator();

  return (
    <NavigationContainer>
      <Stack.Navigator 
        initialRouteName="FristActivity"
        headerMode = "none">
          <Stack.Screen name="FristActivity" component={FristActivity} />
          <Stack.Screen name="OnboardingActivity" component={OnboardingActivity} />
          <Stack.Screen name="LoginActivity" component={LoginActivity} />
          <Stack.Screen name="SignUp1Activity" component={SignUp1Activity} />
          <Stack.Screen name="SignUp2Activity" component={SignUp2Activity} />
          <Stack.Screen name="SignUp2_1Activity" component={SignUp2_1Activity} />
          <Stack.Screen name="SignUp3Activity" component={SignUp3Activity} />
          <Stack.Screen name="SignUp4Activity" component={SignUp4Activity} />
          <Stack.Screen name="SignUp5Activity" component={SignUp5Activity} />
          <Stack.Screen name="SignIn1Activity" component={SignIn1Activity} />
          <Stack.Screen name="SignIn2Activity" component={SignIn2Activity} />
          <Stack.Screen name="WelcomeBackActivity" component={WelcomeBackActivity} />
          <Stack.Screen name="ResetPasswordActivity" component={ResetPasswordActivity} />
          <Stack.Screen name="MainActivity" component={MainActivity} />
          <Stack.Screen name="BookAppointmentActivity" component={BookAppointmentActivity} />
          <Stack.Screen name="ConfirmBookActivity" component={ConfirmBookActivity} />
          <Stack.Screen name="BookDetailsActivity" component={BookDetailsActivity} />
          <Stack.Screen name="TellUsCondition1Activity" component={TellUsCondition1Activity} />
          <Stack.Screen name="TellUsCondition2Activity" component={TellUsCondition2Activity} />
          <Stack.Screen name="TellUsCondition3Activity" component={TellUsCondition3Activity} />
          <Stack.Screen name="ScanQRCodeActivity" component={ScanQRCodeActivity} />
          <Stack.Screen name="CheckInConfirmBookActivity" component={CheckInConfirmBookActivity} />
          <Stack.Screen name="TreatmentDevlarationActivity" component={TreatmentDevlarationActivity} /> 
          <Stack.Screen name="PreConceptionDevlarationActivity" component={PreConceptionDevlarationActivity} /> 
          <Stack.Screen name="ShopActivity" component={ShopActivity} /> 
          <Stack.Screen name="CCTShopActivity" component={CCTShopActivity} /> 
          <Stack.Screen name="ShopProductDetailActivity" component={ShopProductDetailActivity} /> 
          <Stack.Screen name="ProductCartActivity" component={ProductCartActivity} /> 
          <Stack.Screen name="CheckOutActivity" component={CheckOutActivity} /> 
          <Stack.Screen name="CouponActivity" component={CouponActivity} /> 
          <Stack.Screen name="PaymentMethodActivity" component={PaymentMethodActivity} /> 
          <Stack.Screen name="MyWalletActivity" component={MyWalletActivity} /> 
          <Stack.Screen name="TransactionsDetailActivity" component={TransactionsDetailActivity} /> 
          <Stack.Screen name="PostPartumDevlarationActivity" component={PostPartumDevlarationActivity} /> 
          <Stack.Screen name="ShopLikeActivity" component={ShopLikeActivity} /> 
          <Stack.Screen name="ShopViewAllActivity" component={ShopViewAllActivity} />
          <Stack.Screen name="VoucherDetailActivity" component={VoucherDetailActivity} />
          <Stack.Screen name="TopUpActivity" component={TopUpActivity} />
          <Stack.Screen name="TopUpMethodActivity" component={TopUpMethodActivity} />
          <Stack.Screen name="CardDetailsActivity" component={CardDetailsActivity} />
          <Stack.Screen name="TierPrivilegesActivity" component={TierPrivilegesActivity} />
          <Stack.Screen name="AddCardUserActivity" component={AddCardUserActivity} />
          <Stack.Screen name="ReferToAFriendActivity" component={ReferToAFriendActivity} />
          <Stack.Screen name="OurServiceActivity" component={OurServiceActivity} />
          <Stack.Screen name="ConditionsWeTreatActivity" component={ConditionsWeTreatActivity} />
          <Stack.Screen name="EditProfileActivity" component={EditProfileActivity} />
          <Stack.Screen name="SelectedBookServicesActivity" component={SelectedBookServicesActivity} />
          <Stack.Screen name="ToadyBookServicesActivity" component={ToadyBookServicesActivity} />
          <Stack.Screen name="AccountManagementActivity" component={AccountManagementActivity} />
          <Stack.Screen name="EditLoginTypeActivity" component={EditLoginTypeActivity} />
          <Stack.Screen name="ChangePasswordActivity" component={ChangePasswordActivity} />
          <Stack.Screen name="MyOrdersActivity" component={MyOrdersActivity} />
          <Stack.Screen name="OrderDetailsActivity" component={OrderDetailsActivity} />
          <Stack.Screen name="SettingActivity" component={SettingActivity} />
          <Stack.Screen name="ContactUsActivity" component={ContactUsActivity} />
          <Stack.Screen name="FrequentlyAskedQuestionsActivity" component={FrequentlyAskedQuestionsActivity} />  
          <Stack.Screen name="BookCompletedDetailsActivity" component={BookCompletedDetailsActivity} />  
          <Stack.Screen name="UserCardDetailsActivity" component={UserCardDetailsActivity} /> 
          <Stack.Screen name="ShopOrderSummaryActivity" component={ShopOrderSummaryActivity} /> 

   
        </Stack.Navigator>
    </NavigationContainer>



  );
};


export default App;
