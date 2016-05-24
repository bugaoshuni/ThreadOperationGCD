//
//  ViewController.swift
//  多线程
//
//  Created by jichanghe on 16/5/11.
//  Copyright © 2016年 hjc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    var totalTickets = 10       //总共有多少个座位
    var myThread:NSThread!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - EventResponse
    @IBAction func 多线程测试Tap(sender: AnyObject) {
        treadDemo()
        tread线程安全()
        blockOperationNoQueueTest()
        blockOperationTest()
        operationTest()
        testAddOperationWithBlock()
    }
    
    /*
        一、iOS 中 有 4 套多线程方案:
        Pthreads
        NSThread
        GCD
        NSOperation & NSOperationQueue
   */
    // MARK: -   一、Pthreads
    /*
     一、Pthreads：只是拿来充个数，做 iOS 开发几乎不可能用到
     POSIX线程（POSIX threads），简称Pthreads，是线程的POSIX标准。该标准定义了创建和操纵线程的一整套API。在类Unix操作系统（Unix、Linux、Mac OS X等）中，都使用Pthreads作为操作系统的线程。
     简单地说， 在很多操作系统上都通用的 多线程API，所以移植性很强，当然在 iOS 中也是可以的。不过这是基于 c语言 的框架,见：PthreadDemo.m 文件。
    */
 
    
    // MARK: -  二、NSThread
    /*
        二、NSThread

    */

    func treadDemo() {
        //二.1:创建方式1：实例方法- 构造器
        myThread = NSThread(target: self, selector: #selector(downloadImage), object: nil)
        //启动线程
        myThread.start()
        
        //二.2:隐式调用，通过NSObject的Category方法调用：
        //创建方式2：使用类方法,创建并自动启动
        NSThread.detachNewThreadSelector(#selector(downloadImage), toTarget: self, withObject: nil)
        //创建方式2：开启一条后台线程，自动启动线程，但无法获得线程对象
        self.performSelectorInBackground(#selector(downloadImage), withObject: nil) //隐含产生新线程。

//        assert(false, " 下面这句话报错")
//        self.performSelector(#selector(runLoopThread), onThread: myThread, withObject: nil, waitUntilDone: false)//在指定线程中执行，但该线程必须具备run loop。
        self.performSelectorOnMainThread(#selector(downloadImage), withObject: nil, waitUntilDone: true, modes: nil) //在主线程中运行方法，wait表示是否阻塞这个方法的调用，如果为true则等待主线程中运行方法结束。。

        //二.3:非线程调用（NSObject的Category方法）
        //即在当前线程执行， 它们会阻塞当前线程（包括UI线程）：
        self.performSelector(#selector(downloadImage))
        self.performSelector(#selector(downloadImage), withObject: nil)
        self.performSelector(#selector(downloadImage), withObject: nil, withObject: nil)
        
        // 以下调用在当前线程延迟执行，如果当前线程没有显式使用NSRunLoop或已退出就无法执行了，需要注意这点：
        self.performSelector(#selector(downloadImage), withObject: nil, afterDelay: 0)
        self.performSelector(#selector(downloadImage), withObject: nil, afterDelay: 0, inModes: [""])
        //而且它们可以被终止： 专门用来 取消performSelector:withObject:afterDelay:方法所创建的Selector source（内部上就是一个Run Loop的Timer source）。因此该方法和performSelector:withObject:afterDelay:方法一样，只限于当前Run Loop中。
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(downloadImage), object: nil)
        

        
        //1.获得执行该方法的当前线程
        let currentThread = NSThread.currentThread()
        print("当前线程为\(currentThread)")
       
        //2.获得应用程序的主线程
        let mainThread = NSThread.mainThread()
        print("应用程序的主线程\(mainThread)")
        
        //3.判断当前线程是否是主线程
        print("是否是主线程：\(myThread.isMainThread)")
        
        
        //线程的退出
        NSThread.exit()
        //线程的休眠1
        NSThread.sleepForTimeInterval(2.0) //等同于sleep(2);
         //线程的休眠2
        NSThread.sleepUntilDate(NSDate.init(timeIntervalSinceNow: 3.0))
    }
    //定义一个下载图片的方法，线程调用
    func downloadImage() {
        print("downloadImage")
        sleep(1)
    }
    
    func runLoopThread() {
        let currentRunLoop = NSRunLoop.currentRunLoop()
        currentRunLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
        
        print("runLoopThread")
    }


    /*
     　二、2、线程安全
        多线程访问同一个资源  可能会出现数据错乱 ，解决方法：对必要的代码段进行加锁。
     */
    func tread线程安全() {
        //多线程访问资源加锁
        //创建三条线程分别代表售票员A、售票员B、售票员C
        let thread01 = NSThread.init(target: self, selector:#selector(saleTickect), object: nil)
        let thread02 = NSThread.init(target: self, selector:#selector(saleTickect), object: nil);
        let thread03 = NSThread.init(target: self, selector:#selector(saleTickect), object: nil);

        //设置线程的名称
        thread01.name = "售票员A"
        thread02.name = "售票员B"
        thread03.name = "售票员C"

        //开启线程
        thread01.start()
        thread02.start()
        thread03.start()
    }
    
    //模拟售票的函数
    func saleTickect()
    {
        while(true)
        {
            //加互斥锁
            /*
             * 1）同OC中的@synchronized(self) {}
             * 2）objc_sync_enter(self)和objc_sync_exit(self)必须成对使用，把要加锁的代码放在中间
             */
            
            objc_sync_enter(self)
            
            //检查是否有余票，如果有则卖出去一张
            let temp = totalTickets

            NSThread.sleepForTimeInterval(0.4)
            
            if temp > 0 {
                totalTickets = temp - 1
                print("\(NSThread.currentThread().name)卖出去了一张票，座位还剩：\(totalTickets)")
            } else {
                print("\(NSThread.currentThread().name)发现票已经卖完了")
                break
            }
            
//            if totalTickets == 3 {
//                break
//            }
            objc_sync_exit(self)
        }
        
    }
    
    // MARK: -  三、NSOperation & NSOperationQueue
    /*
      三、  NSOperation & NSOperationQueue: 一个面向对象的 异步执行
     NSThread的使用，虽然也可以实现多线程编程，但是需要我们去管理线程的生命周期，还要考虑线程同步、加锁问题，造成一些性能上的开销。
     
     NSOperation是个抽象类，使用它必须用它的子类，
     可以实现它或者使用它定义好的子类：NSBlockOperation。 Swift中将不存在NSInvocationOperation相关APIs
     创建NSOperation子类的对象，把对象添加到NSOperationQueue队列里执行
  
     一个NSOperation对象可以通过调用start方法来执行任务，默认是同步执行的。也可以将NSOperation添加到一个NSOperationQueue(操作队列)中去执行，而且是异步执行的。

     NSOperationQueue 有些类似线程池，我们使用的NSOperation都需要添加到NSOperationQueue中，用来方便管理这些线程。它们应该是一对好兄弟
     
     NSOperation提供了ready，cancelled，executing， finished，这几个状态变化，可以通过KVO来通知改变这些状态，一般场景下你可能使用不到这些，除非你自己继承NSOperation来实现子类的方式来使用，你才需要管理这些状态。
    */
    //还是在主线程 执行的
    func blockOperationNoQueueTest()  {
        let operation1 = NSBlockOperation(block: { _ in
            print("operation1,不用NSOperationQueue")
        })
      operation1.start()
        
    }
    
    /*
    //使用NSOperation的两种方式
    //1:直接用定义好的子类：NSBlockOperation。
     
     NSOperation 定义：
     public func start() //在当前任务状态和依赖关系合适的情况下，启动NSOperation的main方法任务，需要注意缺省实现只是在当前线程运行。如果需要并发执行，子类必须重写这个方法，并且使   asynchronous() 方法返回YES
     public func main() //定义NSOperation的主要任务代码
     public var cancelled: Bool { get }  //当前任务状态是否已标记为取消
     public func cancel() //取消当前NSOperation任务，实质是标记cancelled状态
     public var executing: Bool { get } //NSOperation任务是否在运行
     public var finished: Bool { get }  //NSOperation任务是否已结束
     public var asynchronous: Bool { get }  //是否需要并行
     public var ready: Bool { get }  //是否能准备运行，这个值和任务的依赖关系相关
     public func addDependency(op: NSOperation)  //加上任务的依赖，也就是说依赖的任务都完成后，才能执行当前任务
     public func removeDependency(op: NSOperation)   //取消任务的依赖，依赖的任务关系不会自动消除，必须调用该方法
     public var dependencies: [NSOperation] { get }  //得到所有依赖的NSOperation任务

     以及用于任务同步：
     public func waitUntilFinished() //阻塞当前线程，直到该NSOperation结束。可用于线程执行顺序的同步
      public var completionBlock: (() -> Void)? //设置NSOperation结束后运行的block代码，由于NSOperation有可能被取消，所以这个block运行的代码应该和NSOperation的核心任务无关。
     
    */
    //2、NSBlockOperation NSOperationQueue
    func blockOperationTest() {
        let operation1:NSBlockOperation = NSBlockOperation(block: { [weak self] in
            print("用NSOperationQueue")
            self?.downloadImage()
        })
        

        //添加依赖：依赖的任务都完成后，才能执行当前任务
        let operation2 = NSBlockOperation(block: { _ in
            print("operation2")
        })

        //创建一个NSOperationQueue实例并添加operation
        let queue:NSOperationQueue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 2; //设置最大并发执行数，如果为1则同时只有一个并发任务在运行，可控制顺序执行关系
        
        queue.addOperation(operation1) //加入到执行队列中，如果isReady则开始执行
        queue.addOperation(operation2)
        queue.waitUntilAllOperationsAreFinished() //当前线程等待，直到opA和opB都执行结束
        operation1.addDependency(operation2)    //operation1在operation2执行完成后才开始执行

//        也可以使用同步方法waitUntilFinished：
        let  operation3 = NSBlockOperation(block: { _ in
            operation1.waitUntilFinished()//operation3 线程等待直到operation1执行结束（正常结束或被取消）
        })
        queue.addOperation(operation3)
    }
    
    //3：继承NSOperation 然后把 NSOperation子类的对象放入NSOperationQueue队列中，一旦这个对象被加入到队列，队列就开始处理这个对象，直到这个对象的所有操作完成，然后它被队列释放。
    class DownloadImageOperation: NSOperation {
        override func main(){
            //先判断operation有没有被取消。如果被取消了，那就没有必要往下执行了
            if self.cancelled == true {
                print("operation 被取消了")
                return
            }
            print("DownloadImageOperation 的 main方法")
        }

    }
    
    func operationTest() {
        //创建线程对象
        let downloadImageOperation:DownloadImageOperation = DownloadImageOperation()
        
        //创建一个NSOperationQueue实例并添加operation
        let queue:NSOperationQueue = NSOperationQueue()
        queue.addOperation(downloadImageOperation)
        //暂停前 的方法 还是会执行。暂停后 addOperation 的 暂停
//          queue.suspended = true
        
        let operation2:DownloadImageOperation = DownloadImageOperation()
        let operation3:DownloadImageOperation = DownloadImageOperation()
        let operation4:DownloadImageOperation = DownloadImageOperation()
        let operation5:DownloadImageOperation = DownloadImageOperation()
        let operation6:DownloadImageOperation = DownloadImageOperation()
        queue.addOperation(operation2)
        queue.addOperation(operation3)
        queue.addOperation(operation4)
        queue.addOperation(operation5)
        queue.addOperation(operation6)
        
//         queue.suspended = true
        //取消所有线程操作,已经运行的 不能取消了。如果想取消，要自己判断cancelled
        queue.cancelAllOperations()

        //NSOperationQueue队列里可以加入很多个NSOperation，可以把NSOperationQueue看做一个线程池，可往线程池中添加操作（NSOperation）到队列中。
        //设置并发数
        queue.maxConcurrentOperationCount = 3

        //每个NSOperation完成都会有一个回调表示任务结束
//        //定义一个回调
//        var completionBlock:(() -> Void)?
//        //给operation设置回调
//        downloadImageOperation.completionBlock = completionBlock
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4), dispatch_get_main_queue(), {
//            print("completionBlock  --  Complete")
//        })
    }
    
    func testAddOperationWithBlock() {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        operationQueue.addOperationWithBlock {
            print("testAddOperationWithBlock--addOperationWithBlock")
        }
    }
    
    /*
     NSOperationQueue的其它常用方法：
     
     - (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait; //批量加入执行operation，wait标志是否当前线程等待所有operation结束后，才返回
     - (void)addOperationWithBlock:(void (^)(void))block; //相当于加入一个NSBlockOperation执行任务
     - (NSArray *)operations; //返回已加入执行operation的数组，当某个operation结束后会自动从这个数组清除
     - (NSUInteger)operationCount //返回已加入执行operation的数目
     - (void)setSuspended:(BOOL)b; //是否暂停将要执行的operation，但不会暂停已开始的operation
     - (BOOL)isSuspended; //返回暂停标志
     - (void)cancelAllOperations; //取消所有operation的执行，实质是调用各个operation的cancel方法
     + (id)currentQueue; //返回当前NSOperationQueue，如果当前线程不是在NSOperationQueue上运行则返回nil
     + (id)mainQueue; //返回主线程的NSOperationQueue，缺省总是有一个queue
 */
    
}

