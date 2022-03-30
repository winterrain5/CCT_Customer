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
  FlatList,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions
} from 'react-native';

import TitleBar from '../../../widget/TitleBar';

import DateUtil from '../../../uitl/DateUtil';


export default class VoucherDetailActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
       vaoucher_detail:undefined,
    }
  }


   UNSAFE_componentWillMount(){

    if (this.props.route.params) {
      this.setState({
        vaoucher_detail:this.props.route.params.vaoucher_detail,
      });

    }

  }

  render() {

    const { navigation } = this.props;

    return(

      <View style = {styles.bg}>

        <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

        <SafeAreaView style = {styles.afearea} >

          <TitleBar
            title = {''} 
            navigation={navigation}
            hideLeftArrow = {true}
            hideRightArrow = {false}
            extraData={this.state}/>


            <View style = {{flex:1}}/>


            <View style = {styles.view_content}>


              <View style = {{width:'100%',padding:24}}>

                   <Text style = {styles.text_title}>{this.state.vaoucher_detail ? this.state.vaoucher_detail.name : ''}</Text>

                  <Text style = {styles.text_date}>{(this.state.vaoucher_detail && this.state.vaoucher_detail.expired_time) ? 'Expires on ' + DateUtil.getShowTimeFromDate3(this.state.vaoucher_detail.expired_time)  : ''}</Text>


                  <Text style = {styles.text_content}>{this.state.vaoucher_detail ?  this.state.vaoucher_detail.description : ''}</Text>

              </View>
             

              <View style = {styles.view_line}/>


              <View style = {{width:'100%',padding:24}}>


                  <Text style = {[styles.text_title,{fontSize:18}]}>Terms and Conditions</Text>


                  <View style = {{ width:'100%',flexDirection: 'row',marginTop:18}}>

                      <Text style = {[styles.text_content,{marginTop:0,marginRight:5}]}>·</Text>

                      <Text style = {[styles.text_content,{marginTop:0,fontWeight:'normal'}]}>Redemptions are only valid at Chien Chi Tow and Madam outlets</Text>

                  </View>

                   <View style = {{ width:'100%',flexDirection: 'row',marginTop:5}}>

                      <Text style = {[styles.text_content,{marginTop:0,marginRight:5}]}>·</Text>

                      <Text style = {[styles.text_content,{marginTop:0,fontWeight:'normal'}]}>To redeem voucher, inform our counter staff during payment or use it for in-app store purchases</Text>

                  </View>
                 


                  <View style = {{ width:'100%',flexDirection: 'row',marginTop:5}}>

                      <Text style = {[styles.text_content,{marginTop:0,marginRight:5}]}>·</Text>

                      <Text style = {[styles.text_content,{marginTop:0,fontWeight:'normal'}]}>E-Vouchers are non-refundable and not allowed for cancellations.Valid for 1 year from date of redeption</Text>

                  </View>
                 

                 

              </View>


            </View>




        </SafeAreaView>


        <SafeAreaView style = {styles.afearea_foot} />


      </View>

    );

  }

}



const styles = StyleSheet.create({
  bg: {
    flex:1,
    backgroundColor:'#FFFFFF'
  },
   afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
   view_content:{
    flex:2,
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    backgroundColor:'#FFFFFF'
  },
   scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_user_card:{
    borderRadius:16,
    width:'100%',
    height:184,
  },
  view_user_info:{
    width:'100%',
    height:'100%',
    position:'absolute',
  },
  view_leve:{
    padding:16,
    width:'100%',
    flexDirection: 'row',
    alignItems: 'center'
  },
  view_name_leve:{
    flex:1,
  },
  text_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C',
  },
  image_edit:{
    marginLeft:3,
    width:24,
    height:24,
    paddingBottom:3,
    paddingRight:1,
    justifyContent: 'center',
    alignItems: 'center'
  },
  view_user_info:{
    marginTop:24,
    marginLeft:24,
    padding:24,
    width:'100%',
    height:'100%',
    position:'absolute',
   
  },
  view_name_volue:{
    width:'100%',
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  text_hint:{
    marginTop:8,
    flex:1,
    fontSize:12,
    color:'#828282'
  },
  view_points:{
    paddingLeft:24,
    paddingRight:24,
    width:'100%',
  },
  text_date:{
    marginTop:4,
    width:'100%',
    fontSize:14,
    color:'#828282'
  },
  text_content:{
    marginTop:18,
    fontSize:14,
    color:'#333333',
    fontWeight:'bold',
  },
  view_line:{
    marginTop:44,
    width:'100%',
    height:0.5,
    backgroundColor:'#828282'
  }
});

