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
  NativeModules
} from 'react-native';
let nativeBridge = NativeModules.NativeBridge;
export default class TitleBar extends Component {
  static propTypes = {
    title: PropTypes.string.isRequired,
    navigation: PropTypes.object.isRequired,
    hideLeftArrow: PropTypes.bool,
    hideRightArrow: PropTypes.bool,
    isShowBack:PropTypes.bool,
    pressLeft: PropTypes.func,
    pressRight: PropTypes.func,
    left: PropTypes.string,
    backgroundColor: PropTypes.string,
    titleColor: PropTypes.string,
    right: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.object,
    ]),
    rightImage: Image.propTypes.source,
    LifeImage: Image.propTypes.source,
    statusBarBgColor: PropTypes.string,
    barStyle: PropTypes.string,
  }

  static defaultProps = {
    title: "",
    hideLeftArrow: false,
    hideRightArrow: false,
    isShowBack:false,
    pressRight: () => {},
  }

  back() {
    if (this.props.pressLeft) {
      this.props.pressLeft()
      return
    }
    if (this.props.navigation) {
      this.props.navigation.goBack();
      return
    }
    nativeBridge.goBack();
  }



  render() {
    const {
      backgroundColor,
      titleColor
    } = this.props
    return (


      

      <View style={styles.container}> 

          <View style = {styles.header}>


            {this.renderLeft()}

          
            <View style = {styles.titleView} >
               <Text style = {styles.title}>{this.props.title}</Text>
            </View>

             {this.renderRight()}

        </View>
              
      </View>
    );
  }


  renderLeft() {


    if (this.props.hideLeftArrow) {
      return (
        <TouchableOpacity  
          onPress={this.back.bind(this)}>
             <View style ={styles.rightView} >
                 <Image
                    style={{width:8,height:12}}
                    source={require('../../images/left_0909.png')}
                    resizeMode = 'contain' />
             </View>
        </TouchableOpacity>
      );
    } else {
      return (
        <View style ={styles.rightView} />
      );
    }

  }

  renderRight() {

    if (this.props.hideRightArrow) {

      if (this.props.rightImage && this.props.left) {
        return (

          <TouchableOpacity
             onPress={() => {
                this.props.pressRight()}}> 
              <View style = {styles.rightView}>
                 <Image
                    style={{width:15,height:15}}
                    source={this.props.rightImage}
                    resizeMode = 'contain' />
                  <Text style = {styles.rightText}>{this.props.left}</Text>
         </View>

          </TouchableOpacity>

        );

      } else if (this.props.rightImage) {

        return (
          <TouchableOpacity
                    onPress={() => {
                      this.props.pressRight()}}> 
                    <View style = {styles.rightView}>
                        <Image
                            style={{width:20,height:20,marginTop:2}}
                            source={this.props.rightImage}
                            resizeMode = 'contain' />
                    </View>

                    {this.backView()}

                  </TouchableOpacity>
        );

      } else {

        return (
          <TouchableOpacity
                    onPress={() => {
                      this.props.pressRight()}}> 
                     <Text style = {styles.rightText}>{this.props.left}</Text>
                  </TouchableOpacity>
        );

      }

    } else {

      return (
        <View style = {styles.rightView}/>
      );

    }
  }

backView(){

   if (this.props.isShowBack) {

    return <Text>Back</Text>;

   }else {
    
    return <Text></Text>;

   }

}


}





const styles = StyleSheet.create({

  container: {},

  header: {
    width: '100%',
    height: 50,
    backgroundColor: '#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },

  titleView: {
    height: '100%',
    justifyContent: 'center',
  },

  title: {
    fontSize: 16,
    color: '#FFFFFF',
     fontWeight: 'bold',
  },

  rightView: {
    width: 50,
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },

  rightText: {
    marginTop: 3,
    fontSize: 10,
    color: '#666666',
  },

  line: {
    width: '100%',
    height: 1,
    backgroundColor: '#e1e1e1'
  }
});