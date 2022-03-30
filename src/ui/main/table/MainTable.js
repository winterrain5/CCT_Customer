import React, {
  Component
} from 'react';
import PropTypes from 'prop-types';
import {
  Text,
  View,
  Image,
  StatusBar,
  TouchableOpacity,
  StyleSheet,
  DeviceEventEmitter,
} from 'react-native';



import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';


import HomeScreen from './HomeScreen';
import AppointmentScreen from './AppointmentScreen';
import NotificationScreen from './NotificationScreen';
import ProfileScreen from './ProfileScreen';




const Tab = createBottomTabNavigator();


export default class MainTable extends Component {

  constructor(props) {
    super(props);
    this.state = {
       isOpen: false,

    }
  }


   //注册通知
  componentDidMount(){

      var temporary = this;

      this.emit =  DeviceEventEmitter.addListener('service_view_all',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
          
       });
  }

  componentWillUnmount(){

    this.emit.remove();

  }



	render() {
   		return(
     	 <Tab.Navigator
     	 	screenOptions={({route}) => ({
                    headerShown:false,
                    tabBarActiveTintColor:'#145A7C',
                    tabBarActiveBackgroundColor:'#FFFFFF',
                    tabBarInactiveTintColor:'#BDBDBD',
                    tabBarInactiveBackgroundColor:'#FFFFFFFF',
                    tabBarIcon: ({focused,size}) => {
                        let sourceImg;
                        if (route.name === 'Home') {
                            sourceImg = focused
                            ? require('../../../../images/home_click.png')
                            : require('../../../../images/home.png');
                        } else if (route.name === 'Appointment') {
                            sourceImg = focused
                            ? require('../../../../images/book_click.png')
                            :require('../../../../images/book.png');                
                        } else if (route.name === 'Notification') {
                        	 sourceImg = focused
                            ? require('../../../../images/notification_click.png')
                            :require('../../../../images/notification.png');  
                        }else  {
                        	 sourceImg = focused
                            ? require('../../../../images/profile_click.png')
                            :require('../../../../images/profile.png');  
                        }
                        return <Image style = {styles.image} source={sourceImg}/>;
                    },
                })}>
      		<Tab.Screen name="Home" component={HomeScreen}/>
      		<Tab.Screen name="Appointment" component={AppointmentScreen}  />
      		<Tab.Screen name="Notification" component={NotificationScreen} />
      		<Tab.Screen name="Profile" component={ProfileScreen} />
   		</Tab.Navigator>
      );
  }

}

const styles = StyleSheet.create({

  image: {
    width:20,
    height:20,
  },
});
