//
//  ARSceneViewController.m
//  AR--太阳系
//
//  Created by gz on 2018/1/10.
//  Copyright © 2018年 gz. All rights reserved.
//

#import "ARSceneViewController.h"
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface ARSceneViewController () <ARSCNViewDelegate>
/// 创建sceneView
@property (nonatomic, strong) ARSCNView *arSCNView;
/// 创建会话
@property (nonatomic, strong) ARSession *arSession;
/// 创建追踪
@property (nonatomic, strong) ARConfiguration *arConfiguration;

/// 创建太阳节点
@property (nonatomic, strong) SCNNode *sunNode;
/// 创建地球节点
@property (nonatomic, strong) SCNNode *earthNode;
/// 创建月亮节点
@property (nonatomic, strong) SCNNode *moonNode;
/// 创建地月节点
@property (nonatomic, strong) SCNNode *earthGroupNode;

@end

@implementation ARSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.arSCNView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ARWorldTrackingConfiguration *trackingCongiguration = [[ARWorldTrackingConfiguration alloc] init];
    self.arConfiguration = trackingCongiguration;
    // 自适应灯光,()室内到室外,画面比较柔和
    self.arConfiguration.lightEstimationEnabled = YES;
    [self.arSession runWithConfiguration:self.arConfiguration];
}

#pragma mark ========== 初始化节点 ==========

- (void)initNode {
    self.sunNode = [[SCNNode alloc] init];
    self.earthNode = [[SCNNode alloc] init];
    self.moonNode = [[SCNNode alloc] init];
    self.earthGroupNode = [SCNNode node];
    
    self.sunNode.geometry = [SCNSphere sphereWithRadius:3.0];
    self.earthNode.geometry = [SCNSphere sphereWithRadius:1.0];
    self.moonNode.geometry = [SCNSphere sphereWithRadius:0.5];
    
    self.sunNode.geometry.firstMaterial.multiply.contents = @"sun.jpg";
    self.sunNode.geometry.firstMaterial.diffuse.contents = @"sun.jpg";
    // 强度
    self.sunNode.geometry.firstMaterial.multiply.intensity = 0.5;
    // 光照不变
    self.sunNode.geometry.firstMaterial.lightingModelName = SCNLightingModelConstant;
    
    self.earthNode.geometry.firstMaterial.diffuse.contents = @"earth-diffuse-mini.jpg";
    self.earthNode.geometry.firstMaterial.emission.contents = @"earth-emissive-mini.jpg";
    self.earthNode.geometry.firstMaterial.specular.contents = @"earth-specular-mini.jpg";
    // 光泽
    self.earthNode.geometry.firstMaterial.shininess = 0.1;
    // 反射多少光出去
    self.earthNode.geometry.firstMaterial.specular.intensity = 0.5;
    
    self.moonNode.geometry.firstMaterial.diffuse.contents = @"moon.jpg";
    
    // 重复渲染
    self.sunNode.geometry.firstMaterial.multiply.wrapS =
    self.sunNode.geometry.firstMaterial.diffuse.wrapS =
    self.sunNode.geometry.firstMaterial.multiply.wrapT =
    self.sunNode.geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    
    // 确定节点位置
    self.sunNode.position = SCNVector3Make(0, 5, -30);
    self.earthNode.position = SCNVector3Make(0, 0, 0);
    self.moonNode.position = SCNVector3Make(2, 0, 0);
    self.earthGroupNode.position = SCNVector3Make(8, 0, 0);
    
    // 添加节点
    [self.arSCNView.scene.rootNode addChildNode:self.sunNode];
    
    [self.earthGroupNode addChildNode:self.earthNode];
    [self addSunNodeAnimation];
    [self rotationNode];
}

#pragma mark ========== 添加动画 ==========
// 太阳自转
- (void)addSunNodeAnimation {
    CABasicAnimation *sunBasicAnimation = [CABasicAnimation animationWithKeyPath:@"contentsTransform"];
    // 转一次的时间
    sunBasicAnimation.duration = 10.0;
    // 重复次数
    sunBasicAnimation.repeatCount = FLT_MAX;
    sunBasicAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(1, 1, 1))];
    sunBasicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))];
    [self.sunNode.geometry.firstMaterial.diffuse addAnimation:sunBasicAnimation forKey:@"sun animation"];
}

// 公转
- (void)rotationNode {
    [self.earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:1 z:0 duration:1]]];
    
    SCNNode *moonRotationNode = [SCNNode node];
    [moonRotationNode addChildNode:self.moonNode];
    
    CABasicAnimation *moonBasicAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonBasicAnimation.duration = 1.5;
    moonBasicAnimation.repeatCount = FLT_MAX;
    moonBasicAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [self.moonNode addAnimation:moonBasicAnimation forKey:@"moon rotation"];
    
    CABasicAnimation *moonRotationAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonRotationAnimation.duration = 1;
    moonRotationAnimation.repeatCount = FLT_MAX;
    moonRotationAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [moonRotationNode addAnimation:moonRotationAnimation forKey:@"moon rotation"];
    
    [self.earthGroupNode addChildNode:moonRotationNode];
    
    // 地球绕着太阳转
    SCNNode *earthSunRotationNode = [SCNNode node];
    [self.sunNode addChildNode:earthSunRotationNode];
    [earthSunRotationNode addChildNode:_earthGroupNode];
    
    // 月亮绕着地球转
    moonBasicAnimation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    moonBasicAnimation.duration = 5;
    moonBasicAnimation.repeatCount = FLT_MAX;
    moonBasicAnimation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    [earthSunRotationNode addAnimation:moonBasicAnimation forKey:@"earth rotation around sun"];
}

#pragma mark ========== 懒加载 ==========

- (ARSCNView *)arSCNView {
    if (!_arSCNView) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
        _arSCNView.delegate = self;
        _arSCNView.session = self.arSession;
        // 灯光自适应
        _arSCNView.automaticallyUpdatesLighting = YES;
        
        [self initNode];
    }
    return _arSCNView;
}

- (ARSession *)arSession {
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
    }
    return _arSession;
}

@end
