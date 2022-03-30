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
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions
} from 'react-native';

import TitleBar from '../../widget/TitleBar';


import { QRScannerView } from 'react-native-qrcode-scanner-view';


export default class ScanQRCodeActivity extends Component {

    constructor(props) {
      super(props);
      this.state = { 
     
      }
    }



    renderTitleBar = () => <Text style={{color:'white',textAlign:'center',padding:16}}>1234</Text>

    renderMenu = () => <Text style={{color:'white',textAlign:'center',padding:16}}>145</Text>


    barcodeReceived = (event) => { 
      
      const {
        navigation
      } = this.props;
    
      if (navigation) {
        navigation.goBack();
     }
    
    
    };





    render() {



      const { navigation } = this.props;


      return (

        <View style = {styles.bg}>


          <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

          <SafeAreaView style = {styles.afearea} >


              <TitleBar
                title = {""} 
                navigation={navigation}
                hideLeftArrow = {true}
                hideRightArrow = {false}
                extraData={this.state}/>  

              <QRScannerView

                  hintText = ''
                  onScanResult={ this.barcodeReceived }
                  renderHeaderView={ this.renderTitleBar }
                  renderFooterView={ this.renderMenu }
                  scanBarAnimateReverse={ true }/>



          </ScanQRCodeActivity>        

          <SafeAreaView style = {styles.afearea_foot} />
          
          <CoverLayer ref={ref => this.coverLayer = ref}/>



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
    padding:24,
    flex:1,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  }
 
});


