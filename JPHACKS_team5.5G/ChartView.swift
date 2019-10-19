//
//  ChartView.swift
//  
//
//  Created by 神田章博 on 2019/10/19.
//

import UIKit

class ChartView:UIView {
    let caShapeLayerForBase:CAShapeLayer = CAShapeLayer.init()
    let caShapeLayerForValue:CAShapeLayer = CAShapeLayer.init()

    func drawChart(rate:Double){
        //グラフを表示
        drawBaseChart()
        drawValueChart(rate: rate)

        //グラフをアニメーションで表示
        let caBasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        caBasicAnimation.duration = 2.0
        caBasicAnimation.fromValue = 0.0
        caBasicAnimation.toValue = 1.0
        caShapeLayerForValue.add(caBasicAnimation, forKey: "chartAnimation")
    }

    /**
     円グラフの軸となる円を表示
     */
    private func drawBaseChart(){
        let shapeFrame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        caShapeLayerForBase.frame = shapeFrame
        caShapeLayerForBase.strokeColor = UIColor(displayP3Red: 1, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        caShapeLayerForBase.fillColor = UIColor.clear.cgColor
        caShapeLayerForBase.lineWidth = 50
        caShapeLayerForBase.lineCap = .round

        let startAngle:CGFloat = CGFloat(0.0)
        let endAngle:CGFloat = CGFloat(Double.pi * 2.0)

        caShapeLayerForBase.path = UIBezierPath.init(arcCenter: CGPoint.init(x: shapeFrame.size.width / 2.0, y: shapeFrame.size.height / 2.0),radius: shapeFrame.size.width / 2.0,startAngle: startAngle,endAngle: endAngle,clockwise: true).cgPath
        self.layer.addSublayer(caShapeLayerForBase)
    }

    /**
     円グラフの値を示す円(半円)を表示
     @param rate 円グラフの値の%値
     */
    private func drawValueChart(rate:Double){
        //CAShareLayerを描く大きさを定義
        let shapeFrame = CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        caShapeLayerForValue.frame = shapeFrame

        //CAShareLayerのデザインを定義
        caShapeLayerForValue.strokeColor = UIColor(displayP3Red: 1, green: 0.4, blue: 0.4, alpha: 1).cgColor
        caShapeLayerForValue.fillColor = UIColor.clear.cgColor
        caShapeLayerForValue.lineWidth = 50
        caShapeLayerForValue.lineCap = .round

        //開始位置を時計の0時の位置にする
        let startAngle:CGFloat = CGFloat(-1 * Double.pi / 2.0)

        //終了位置を時計の0時起点で引数渡しされた割合の位置にする
        let endAngle :CGFloat = CGFloat(rate / 100 * Double.pi * 2.0 - (Double.pi / 2.0))

        //UIBezierPathを使用して半円を定義
        caShapeLayerForValue.path = UIBezierPath.init(arcCenter: CGPoint.init(x: shapeFrame.size.width / 2.0, y: shapeFrame.size.height / 2.0),radius: shapeFrame.size.width / 2.0,startAngle: startAngle,endAngle: endAngle,clockwise: true).cgPath
        self.layer.addSublayer(caShapeLayerForValue)
    }
}
