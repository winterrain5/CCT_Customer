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
  DeviceEventEmitter
} from 'react-native';


export default class WelcomeBackActivity extends Component {

  constructor(props) {
    super(props);
    this.state = {
      userBean:undefined,
      number:undefined,
    }
  }


  componentDidMount(){


    if (this.props.route.params) {

      this.setState({
        number:this.props.route.params.number,
        userBean:this.props.route.params.userBean,
      });
    }

  }

  toSignUp2_1Activity(){

       const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('SignUp2_1Activity',{
        'number':this.state.number,
        'userBean':this.state.userBean,
      });
    }

  }





  render() {

     return (

        <View style = {styles.bg}>

            <StatusBar barStyle="dark-content" />


            <SafeAreaView style = {styles.bg}>


              <View style = {styles.view_content}>

                <View style={styles.viewpager_item}>
                  <Image style = {styles.viewpager_item_image} 
                    resizeMode = 'contain' 
                    source={require('../../../images/graphic_progressxxxhdpi.png')}/>

                  <Text style = {styles.viewpager_item_title} >Welcome Back!</Text> 

                  <Text style = {styles.viewpager_item_content}>Thank you for being a customer of Chien Chi Tow,  let’s proceed to registering you as a Chien Chi Tow App user.</Text>   
              </View>



              </View>




              <View style = {styles.next_view}>

                <TouchableOpacity style = {[styles.next_layout,{backgroundColor:'#C44729'}]}  
                  activeOpacity = { 0.8}
                  onPress={this.toSignUp2_1Activity.bind(this)}>


                  <Text style = {styles.next_text}>Let's Go!</Text>



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
    backgroundColor:'#FFFFFF'
  },
  next_view:{
      marginBottom:56,
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
  view_content:{
    flex:1,
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


});
