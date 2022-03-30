import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  DeviceEventEmitter
} from 'react-native';


import Swiper from 'react-native-swiper';

import DeviceStorage from '../../uitl/DeviceStorage';

import {CommonActions,useNavigation} from '@react-navigation/native';


export default class OnboardingActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
            page: 0,
        };
  }


 onPageSelected = (e) => {
      this.setState({page: e.nativeEvent.position});

  };




clickNext(){

  if (this.state.page == 3) {
    const { navigation } = this.props;
    
    if (navigation) {

      // navigation.replace('LoginActivity');
      DeviceStorage.save('isFirst', true);

      navigation.dispatch(
        CommonActions.reset({
          index: 0,
          routes: [
            { name: 'LoginActivity' },
          ],
       })
      );
    }
  }else {

     this.setState({
        page:this.state.page + 1,
     }); 


  }


}



 render() {

  
    return (

      <View style = {styles.bg}>
        <StatusBar barStyle="dark-content" />
          <SafeAreaView style = {styles.viewpager}>
           <Swiper 
              loop={false}  
              index = {this.state.page}
              showsPagination={false} 
              autoplay={false} 
              horizontal={true}
              onIndexChanged={(index) => {
               
                this.setState({
                    page: index,
                });
              }}  

              >
              <View style={styles.viewpager_item} key="1">
                <Image style = {styles.viewpager_item_image} 
                    resizeMode = 'contain' 
                    source={require('../../../images/graphic_bookingxxhdpi.png')}/>

                <Text style = {styles.viewpager_item_title} >Efficient Booking</Text> 

                <Text style = {styles.viewpager_item_content}>Skip the queue and cumbersome phone conversation. Scheduling an appointment with us is now a few taps away.</Text>   
              </View>
               <View style={styles.viewpager_item} key="2">
                <Image style = {styles.viewpager_item_image} 
                    resizeMode = 'contain' 
                    source={require('../../../images/graphic_voucherxxxhdpi.png')}/>


                <Text style = {styles.viewpager_item_title} >Be the first to receive amazing deals</Text> 

                <Text style = {styles.viewpager_item_content}>Be instantly informed when we have amazing deals. Enjoy incredible savings for your long term wellness needs.</Text>   
              </View>
               <View style={styles.viewpager_item} key="3">
                <Image style = {styles.viewpager_item_image} 
                    resizeMode = 'contain' 
                    source={require('../../../images/graphic_progressxxxhdpi.png')}/>

                <Text style = {styles.viewpager_item_title}>Keep track of your Progress</Text> 

                <Text style = {styles.viewpager_item_content}>Manage your appointments, be reminded of upcoming ones and revisit your consultation notes from your previous sessions.</Text>   
              </View>

               <View style={styles.viewpager_item} key="4">
                <Image style = {styles.viewpager_item_image} 
                    resizeMode = 'contain' 
                    source={require('../../../images/graphic_loyaltyxxxhdpi.png')}/>

                <Text style = {styles.viewpager_item_title}>Gain Loyalty Point</Text> 

                <Text style = {styles.viewpager_item_content}>Be rewarded on your health and wellness journey with us. Track and redeem your loyalty points at your fingertips.</Text>   
              </View>
          </Swiper>


          <View style = {styles.indicator_view}>


            <View style = {[styles.indicator_item,{backgroundColor:this.state.page == 0 ? '#145A7C':'#BDBDBD'}]}/>
            <View style = {[styles.indicator_item,{backgroundColor:this.state.page == 1 ? '#145A7C':'#BDBDBD'}]}/>
            <View style = {[styles.indicator_item,{backgroundColor:this.state.page == 2 ? '#145A7C':'#BDBDBD'}]}/>
            <View style = {[styles.indicator_item,{backgroundColor:this.state.page == 3 ? '#145A7C':'#BDBDBD'}]}/>


          </View>




          <View style = {styles.next_view}>

             <TouchableOpacity style = {[styles.next_layout,{backgroundColor: '#C44729'}]}  
              activeOpacity = {0.8}
              onPress={this.clickNext.bind(this)}>


              <Text style = {styles.next_text}>{this.state.page == 3 ? 'Get Started' : 'Next'}</Text>



            </TouchableOpacity>


          </View> 

        </SafeAreaView>  

      
      </View>


    );
  }

}

const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FAF3EB'
  },
  viewpager: {
    flex:1,
    backgroundColor:'#FAF3EB'
  },
  viewpager_item:{
    flex:1,
    padding:52,
    alignItems: 'center'
  },
  viewpager_item_image:{
      marginTop: 75,
      width:100,
      height:100
  },
  viewpager_item_title:{
      width:'100%',
      marginTop: 110,
      fontSize: 24,
      color: '#145A7C',
      fontWeight: 'bold',
      textAlign: 'center'
  },
   viewpager_item_content:{
      width:'100%',
      marginTop:16,
      fontSize: 16,
      color: '#333333',
      textAlign: 'center',
      letterSpacing:1,
  },
  next_view:{
      marginBottom:74,
      width:'100%',
      paddingRight:48

  },
  next_layout:{
      marginLeft:24,
      marginRight:24,
      width:'100%',
      height:44,
      borderRadius: 50,
      justifyContent: 'center',
      alignItems: 'center'

  },

  next_text :{

      fontSize: 14,
      color: '#FFFFFF',
      fontWeight: 'bold',

  },
  indicator_view:{
      width:'100%',
      flexDirection: 'row',
      justifyContent: 'center',


  },
  indicator_item:{
      width:24,
      height:4,
      backgroundColor:'#000000',
      borderRadius: 50,
      marginBottom:32,
      marginLeft:8,

  }

});
