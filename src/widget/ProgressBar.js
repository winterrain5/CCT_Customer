// ProgressBar.js 进度条
'use strict';
import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {StyleSheet, View, ScrollView, LayoutAnimation} from 'react-native';

let viewWidth = 0
export default class ProgressBar extends Component {
  constructor(props) {
    super(props);
  }
  componentWillUpdate(){
    LayoutAnimation.linear();
  }
  render() {
    const { progress, height, barColor, fillColor } = this.props
    return (
      <View style={{
        backgroundColor: barColor,
        height,
        borderRadius: height / 2
      }} onLayout={(event)=>{
        viewWidth = event.nativeEvent.layout.width
      }}>
        <View style={{
          backgroundColor: fillColor,
          height,
          width: viewWidth * progress,
          borderRadius: height / 2
        }} />
      </View>
    )
  }
}
ProgressBar.propTypes = {
  progress: PropTypes.number,   // 进度 0-1
  height: PropTypes.number,     // 进度条高度
  barColor: PropTypes.string,   // 进度条的背景色
  fillColor: PropTypes.string,  // 进度条填充色
}
ProgressBar.defaultProps = {
  progress: 0.2,
  height: 4,
  barColor: '#d7dada',
  fillColor: '#FFFFFF'
}
