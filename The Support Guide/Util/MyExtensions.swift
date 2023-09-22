//
//  MyExtensions.swift
//  The Support Guide
//
//  Created by Vijay Rathore on 26/04/23.
//


import UIKit
import MBProgressHUD
import TTGSnackbar
import GoogleSignIn
import Firebase
import FirebaseFirestoreSwift
import FirebaseFunctions
import PassKit
import StripeApplePay


extension UITextField {
          
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        
        self.rightView = paddingView
        self.rightViewMode = .always
        
    }
    
    func changePlaceholderColour()  {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)])
    }
    
    func addBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        setLeftPaddingPoints(10)
        setRightPaddingPoints(10)
    }
    
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftIcons(icon: UIImage) {
        
        let padding = 8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    
    
    
    
    /// set icon of 20x20 with left padding of 8px
    func setRightIcons(icon: UIImage) {
        
        let padding = 8
        let size = 12
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: -padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    
}

extension Date {
    
    public func setTime(hour: Int, min: Int, timeZoneAbbrev: String = "UTC") -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)
        
        components.timeZone = TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        
        return cal.date(from: components)
    }
    
    func removeTimeStamp() -> Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return  nil
        }
        return date
    }
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}



extension UIViewController {
    
    

    
    public func createCustomerForStripe(name : String, email : String, completion : @escaping (_ customer_id : String?, _ error : String?)->Void){
        // MARK: Fetch the PaymentIntent and Customer information from the backend
       
        // var request = URLRequest(url: backendCheckoutUrl)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "name=\(name)&email=\(email)".data(using: String.Encoding.utf8)!)
        
        var url = Constants.BASE_URL
        if Constants.isLive {
            url = url + "live/create_customer.php"
        }
        else {
            url = url + "test/test_create_customer.php"
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
            
            
            
       
            
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customer_id = json["id"] as? String else {
                completion(nil, "error")
                return
            }
            
            completion(customer_id,nil)
           
 
        })
        task.resume()
    }

    public func createPaymentIntentForStripe(amount : String, currency : String, customer : String,email : String, completion : @escaping (_ client_secret : String?,_ secret : String?) -> Void){
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        
        // var request = URLRequest(url: backendCheckoutUrl)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "amount=\(amount)&currency=\(currency)&customer=\(customer)&email=\(email)".data(using: String.Encoding.utf8)!)
        
        var url = Constants.BASE_URL
        if Constants.isLive {
            url = url + "live/create_payment_intent.php"
        }
        else {
            url = url + "test/test_create_payment_intent.php"
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
            
          
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let secret = json["secret"] as? String,
                  let client_secret = json["client_secret"] as? String else {
                
                
                completion(nil,nil)
                
                return
            }
            
            completion(client_secret, secret)
 
        })
        task.resume()
    }
    func retrieveSubscription(subscriptionId: String, completion : @escaping (_ expireDate : Date?, _ subscriptionStatus : String?, _ interval :String?) -> Void){
        // MARK: Fetch the PaymentIntent and Customer information from the backend
        
        // var request = URLRequest(url: backendCheckoutUrl)
        // let parameterDictionary = ["amount" : amount, "currency" : currency]
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        var url = Constants.BASE_URL
        if Constants.isLive {
            url = url + "live/retrieve_subscription.php"
        }
        else {
            url = url + "test/test_retrieve_subscription.php"
        }
        
        
        let postData = NSMutableData(data: "subscription_id=\(subscriptionId)".data(using: String.Encoding.utf8)!)
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let end_time = json["current_period_end"] as? Int,
                  let status = json["status"] as? String,
                  let items = json["items"] as? [String : AnyObject],
                  let data = items["data"] as? [String : AnyObject],
                  let data0 = data["0"] as? [String : AnyObject],
                  let price = data0["price"] as? [String : AnyObject],
                  let recurring = price["recurring"] as? [String : AnyObject],
                 let interval = recurring["interval"] as? String
            else {
                completion(nil, nil, nil)
                return
            }

            let date = Date(timeIntervalSince1970: TimeInterval(end_time))
            
            
            
            completion(date,status,interval)
            
            
            
        })
        task.resume()
    }
    
    func getRedeemHistory(userId : String,completion : @escaping (Array<RedeemHistoryModel>?,Error?) -> Void){
        Firestore.firestore().collection("RedeemHistory").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var redeemHistoryModels = Array<RedeemHistoryModel>()
                for qdr in snapshot.documents {
                    if let redeemHistory = try? qdr.data(as: RedeemHistoryModel.self) {
                        redeemHistoryModels.append(redeemHistory)
                    }
                }
                completion(redeemHistoryModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func getAllFundraiser(completion : @escaping (Array<FundraiserModel>?,Error?) -> Void){
        Firestore.firestore().collection("Fundraisers").order(by: "name").getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var fundraiserModels = Array<FundraiserModel>()
                for qdr in snapshot.documents {
                    if let fundRaiserModel = try? qdr.data(as: FundraiserModel.self) {
                        fundraiserModels.append(fundRaiserModel)
                    }
                }
                completion(fundraiserModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func getAllFundraiserBy(franchiseId : String, completion : @escaping (Array<FundraiserModel>?,Error?) -> Void){
        Firestore.firestore().collection("Fundraisers").order(by: "name").whereField("franchiseId", isEqualTo: franchiseId).getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var fundraiserModels = Array<FundraiserModel>()
                for qdr in snapshot.documents {
                    if let fundRaiserModel = try? qdr.data(as: FundraiserModel.self) {
                        fundraiserModels.append(fundRaiserModel)
                    }
                }
                completion(fundraiserModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func getAllFundraiserTransactionsBy(memberId : String?, franchiseId : String?,  completion : @escaping (Array<FundraiserTransactionModel>?,Error?) -> Void){
      

        let collectionRef =  Firestore.firestore().collection("FundraiserTransactions")
        var query : Query?
        if memberId != nil {
             query = collectionRef.whereField("memberId", isEqualTo: memberId!)
        }
        query?.order(by: "date",descending: true).getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var fundraiserTransactionModels = Array<FundraiserTransactionModel>()
                for qdr in snapshot.documents {
                    if let fundraiserTransactionModel = try? qdr.data(as: FundraiserTransactionModel.self) {
                        fundraiserTransactionModels.append(fundraiserTransactionModel)
                    }
                }
                completion(fundraiserTransactionModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    func getAllBusinessTransactionsBy(franchiseId : String,  completion : @escaping (Array<BusinessTransactionModel>?,Error?) -> Void){
        Firestore.firestore().collection("BusinessTransactions").whereField("franchiseId", isEqualTo: franchiseId).order(by: "date",descending: true).getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var businessTransactionModels = Array<BusinessTransactionModel>()
                for qdr in snapshot.documents {
                    if let businessTransactionModel = try? qdr.data(as: BusinessTransactionModel.self) {
                        businessTransactionModels.append(businessTransactionModel)
                    }
                }
                completion(businessTransactionModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func getAllFundraiserMembersRecentActivities(fundraiserId : String,completion : @escaping (Array<SalesMemberModel>?,Error?) -> Void){
        Firestore.firestore().collection("Fundraisers").document(fundraiserId).collection("Members").order(by: "totalSaleUpdate", descending: true).addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var memberModels = Array<SalesMemberModel>()
                for qdr in snapshot.documents {
                    if let memberModel = try? qdr.data(as: SalesMemberModel.self) {
                        memberModels.append(memberModel)
                    }
                }
                completion(memberModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func getAllFundraiserMembers(fundraiserId : String,completion : @escaping (Array<SalesMemberModel>?,Error?) -> Void){
        Firestore.firestore().collection("Fundraisers").document(fundraiserId).collection("Members").order(by: "name").addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                var memberModels = Array<SalesMemberModel>()
                for qdr in snapshot.documents {
                    if let memberModel = try? qdr.data(as: SalesMemberModel.self) {
                        memberModels.append(memberModel)
                    }
                }
                completion(memberModels, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func loginWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting : self) { [unowned self] result, error in
            
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
              let idToken = user.idToken?.tokenString
            else {
             return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            self.authWithFirebase(credential: credential,type: "google", displayName: "")
            
        }
    }
    
    
    func updateFranchise(franchiseModel : FranchiseModel, completion : @escaping (_ error : String?)->Void){
        
        try? FirebaseStoreManager.db.collection("Franchises").document(franchiseModel.uid ?? "123").setData(from: franchiseModel, merge : true) { error in
            if let error = error {
                completion(error.localizedDescription)
            }
            else  {
                completion(nil)
            }
        }
        
    }
    
    func handleApplePay(amount : Int, delegate: _stpinternal_STPApplePayContextDelegateBase){
        
        let merchantIdentifier = Constants.APPLE_MERCHANT_ID
        
        if StripeAPI.deviceSupportsApplePay() {
            let paymentRequest = StripeAPI.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: "US", currency: "USD")

               // Configure the line items on the payment request
               paymentRequest.paymentSummaryItems = [
                   // The final line should represent your company;
                   // it'll be prepended with the word "Pay" (that is, "Pay iHats, Inc $50")
                PKPaymentSummaryItem(label: "Pay The Support Guide", amount: NSDecimalNumber(value: amount)),
               ]
            
            if let applePayContext = STPApplePayContext(paymentRequest: paymentRequest, delegate: delegate) {
                    // Present Apple Pay payment sheet
                    applePayContext.presentApplePay(completion: nil)
                } else {
                    // There is a problem with your Apple Pay configuration
                }
        }
        else {
            showToast(message:  "Your device do not support apple pay.")
        }
        
        
    }
    
    func getFranchiseAccountCount(completion : @escaping (Int)-> Void) {
        let query = FirebaseStoreManager.db.collection("Franchises")
        let countQuery = query.count
        
            countQuery.getAggregation(source: .server) { snapshot, error in
                if let snapshot = snapshot {
                    completion(Int(truncating: snapshot.count))
                }
                else {
                    completion(0)
                }
            }
         
    }
    
    func getB2BAccountsCount(by franchiseId : String, completion : @escaping (Int)-> Void) {
        let query = FirebaseStoreManager.db.collection("Businesses").whereField("franchiseId", isEqualTo: franchiseId)
        let countQuery = query.count
        
            countQuery.getAggregation(source: .server) { snapshot, error in
                if let snapshot = snapshot {
                    completion(Int(truncating: snapshot.count))
                }
                else {
                    completion(0)
                }
            }
         
    }
    
    func getFundraiserAccountsCount(by franchiseId : String, completion : @escaping (Int)-> Void) {
        let query = FirebaseStoreManager.db.collection("Fundraisers").whereField("franchiseId", isEqualTo: franchiseId)
        let countQuery = query.count
        
            countQuery.getAggregation(source: .server) { snapshot, error in
                if let snapshot = snapshot {
                    completion(Int(truncating: snapshot.count))
                }
                else {
                    completion(0)
                }
            }
         
    }
    
    func getB2BVouchersCount(by b2bId : String, completion : @escaping (Int)-> Void) {
        let query = FirebaseStoreManager.db.collection("Businesses").document(b2bId).collection("Vouchers").order(by: "valid",descending: true).whereField("valid", isGreaterThanOrEqualTo: Date())
        let countQuery = query.count
        
            countQuery.getAggregation(source: .server) { snapshot, error in
                if let snapshot = snapshot {
                    completion(Int(truncating: snapshot.count))
                }
                else {
                    completion(0)
                }
            }
         
    }
    
    func addB2B(b2bModel : B2BModel, completion : @escaping (_ error : String?)->Void){
        
       
        
        let batch = FirebaseStoreManager.db.batch()
        
        let recentlyModel = RecentlyAddedModel()
        recentlyModel.uid = b2bModel.uid
        recentlyModel.date = Date()
        recentlyModel.type = "b2b"
        
        let userModel = UserModel()
        userModel.uid = b2bModel.uid
        userModel.userType = "b2b"
        try! batch.setData(from: recentlyModel, forDocument: FirebaseStoreManager.db.collection("Franchises").document(b2bModel.franchiseId ?? "123").collection("Recents").document(b2bModel.uid ?? "123"))
        try! batch.setData(from: b2bModel, forDocument: FirebaseStoreManager.db.collection("Businesses").document(b2bModel.uid ?? "123"))
        try! batch.setData(from: userModel, forDocument: FirebaseStoreManager.db.collection("Users").document(userModel.uid ?? "123"))
        batch.setData(["totalBusinessEarning" : FieldValue.increment(Int64(b2bModel.amount ?? 0))], forDocument: Firestore.firestore().collection("Franchises").document(b2bModel.franchiseId ?? "123"),merge: true)
       
        let businessTransactionModel = BusinessTransactionModel()
        businessTransactionModel.amount = b2bModel.amount
        businessTransactionModel.businessId = b2bModel.uid
        businessTransactionModel.date = Date()
        businessTransactionModel.franchiseId = b2bModel.franchiseId
        businessTransactionModel.type = "J"
        let id = Firestore.firestore().collection("BusinessTransactions").document().documentID
        businessTransactionModel.id = id
        try! batch.setData(from: businessTransactionModel, forDocument: Firestore.firestore().collection("BusinessTransactions").document(id))
    
        batch.commit { error in
            if let error = error {
                completion(error.localizedDescription)
            }
            else  {
                completion(nil)
            }
        }
        
    }
    
    func updateB2B(b2bModel : B2BModel, completion : @escaping (_ error : String?)->Void){
        
        try? FirebaseStoreManager.db.collection("Businesses").document(b2bModel.uid ?? "123").setData(from: b2bModel, merge : true) { error in
            if let error = error {
                completion(error.localizedDescription)
            }
            else  {
                completion(nil)
            }
        }
        
    }
    
    
    func updateFundraiser(fundraiserModel : FundraiserModel, completion : @escaping (_ error : String?)->Void){
        
        try? FirebaseStoreManager.db.collection("Fundraisers").document(fundraiserModel.uid ?? "123").setData(from: fundraiserModel, merge : true) { error in
            if let error = error {
                completion(error.localizedDescription)
            }
            else  {
                completion(nil)
            }
        }
        
    }
    
    
    func getB2bAndFundraiser(by uid : String,franchiseId : String, type : String, completion : @escaping (_ businessModel : B2BModel?,_ fundraiserModel : FundraiserModel? ,_ error :String?)->Void) {
        FirebaseStoreManager.db.collection(type).document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil,nil, error.localizedDescription)
            }
            else {
                if let snapshot = snapshot, snapshot.exists {
                    
                    if type == "Businesses" {
                        if let b2bModel = try? snapshot.data(as: B2BModel.self) {
                            completion(b2bModel, nil, nil)
                        }
                    }
                    else {
                        if let fundrasierModel = try? snapshot.data(as: FundraiserModel.self) {
                            completion(nil, fundrasierModel, nil)
                        }
                    }
                }
                else {
                    completion(nil, nil,"Does not exist")
                }
            }
        }
        
        
    }
    
 
    
    func addFundraiser(fundRaiserModel : FundraiserModel, completion : @escaping (_ error : String?)->Void){
        
        let batch = FirebaseStoreManager.db.batch()
        
        let recentlyModel = RecentlyAddedModel()
        recentlyModel.uid = fundRaiserModel.uid
        recentlyModel.date = Date()
        recentlyModel.type = "sales"
        
        let userModel = UserModel()
        userModel.uid = fundRaiserModel.uid
        userModel.userType = "sales"
        try! batch.setData(from: recentlyModel, forDocument: FirebaseStoreManager.db.collection("Franchises").document(fundRaiserModel.franchiseId ?? "123").collection("Recents").document(fundRaiserModel.uid ?? "123"))
        try! batch.setData(from: fundRaiserModel, forDocument: FirebaseStoreManager.db.collection("Fundraisers").document(fundRaiserModel.uid ?? "123"))
        try! batch.setData(from: userModel, forDocument: FirebaseStoreManager.db.collection("Users").document(userModel.uid ?? "123"))
        batch.commit { error in
            if let error = error {
                completion(error.localizedDescription)
            }
            else  {
                completion(nil)
            }
        }
        
    }
    
    func addPipelineNote(franchiseId : String, pipelineId : String, noteModel : NoteModel, completion : @escaping (Bool,String?)->Void){
        let id = FirebaseStoreManager.db.collection("Franchises").document(franchiseId).collection("Pipelines").document(pipelineId).collection("Notes").document().documentID
        noteModel.id = id
        
        try? FirebaseStoreManager.db.collection("Franchises").document(franchiseId).collection("Pipelines").document(pipelineId).collection("Notes").document(id).setData(from: noteModel, completion: { error in
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        })
        
        
        
    }
    func getAllNotes(franchiseId : String, pipelineId : String, completion : @escaping (Array<NoteModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Franchises").document(franchiseId).collection("Pipelines").document(pipelineId).collection("Notes").order(by: "time",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let noteModels = snapshot.documents.compactMap{ try? $0.data(as: NoteModel.self) }
                    completion(noteModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    

    func addFranchise(franchiseModel : FranchiseModel, completion : @escaping (_ error : String?)->Void){
        
        let batch = FirebaseStoreManager.db.batch()
        let userModel = UserModel()
        userModel.uid = franchiseModel.uid
        userModel.userType = "franchise"
        try! batch.setData(from: franchiseModel, forDocument: FirebaseStoreManager.db.collection("Franchises").document(franchiseModel.uid ?? "123"))
        try! batch.setData(from: userModel, forDocument: FirebaseStoreManager.db.collection("Users").document(userModel.uid ?? "123"))
        batch.commit { error in
            if let error = error {
                completion(error.localizedDescription)
            }
            else  {
                completion(nil)
            }
        }
        
    }
    func getAllVouchers(by b2bId : String , completion : @escaping (Array<VoucherModel>?, String?)->Void) {
        
        FirebaseStoreManager.db.collection("Businesses").document(b2bId).collection("Vouchers").order(by: "valid",descending: true).whereField("valid", isGreaterThanOrEqualTo: Date())
            .addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let voucherModels = snapshot.documents.compactMap{ try? $0.data(as: VoucherModel.self) }
                    completion(voucherModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    
    }
    
    func getAllStore(by b2bId : String , completion : @escaping (Array<StoreModel>?, String?)->Void) {
        
        FirebaseStoreManager.db.collection("Businesses").document(b2bId).collection("Stores").order(by: "date",descending: true)
            .addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let storeModels = snapshot.documents.compactMap{ try? $0.data(as: StoreModel.self) }
                    completion(storeModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    
    }
    
    func getAllRecentsB2BAndSales(franchiseId : String, completion : @escaping (Array<RecentlyAddedModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Franchises").document(franchiseId).collection("Recents").order(by: "date",descending: true).limit(to: 20).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let recentsModels = snapshot.documents.compactMap{ try? $0.data(as: RecentlyAddedModel.self) }
                    completion(recentsModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func getAllFranchises(completion : @escaping (Array<FranchiseModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Franchises").order(by: "name").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let franchiseModels = snapshot.documents.compactMap{ try? $0.data(as: FranchiseModel.self) }
                    completion(franchiseModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func getAllPipelines(by franchiseId : String,  completion : @escaping (Array<PipelineModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Franchises").document(franchiseId).collection("Pipelines").order(by: "createDate",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let pipelineModels = snapshot.documents.compactMap{ try? $0.data(as: PipelineModel.self) }
                    completion(pipelineModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func getAllAdminGoals(by franchiseId : String,  completion : @escaping (Array<GoalModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Admins").document(franchiseId).collection("Goals").order(by: "goalCreate",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
              
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    var goalModels = Array<GoalModel>()
                    for qdr in snapshot.documents {
                        if let goalModel = try? qdr.data(as: GoalModel.self) {
                            if (goalModel.finalDate ?? Date()) > Date() {
                                goalModels.append(goalModel)
                            }
                        }
                    }
                    
                   
                    completion(goalModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func getAllFundraiserGoals(by fundraiserId : String,  completion : @escaping (Array<GoalModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Fundraisers").document(fundraiserId).collection("Goals").order(by: "goalCreate",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    var goalModels = Array<GoalModel>()
                    for qdr in snapshot.documents {
                        if let goalModel = try? qdr.data(as: GoalModel.self) {
                            if (goalModel.finalDate ?? Date()) > Date() {
                                goalModels.append(goalModel)
                            }
                        }
                    }
                    completion(goalModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    
    func getAllFranchiseGoals(by franchiseId : String,  completion : @escaping (Array<GoalModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Franchises").document(franchiseId).collection("Goals").order(by: "goalCreate",descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    var goalModels = Array<GoalModel>()
                    for qdr in snapshot.documents {
                        if let goalModel = try? qdr.data(as: GoalModel.self) {
                            if (goalModel.finalDate ?? Date()) > Date() {
                                goalModels.append(goalModel)
                            }
                        }
                    }
                    completion(goalModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func getFundraisers(by franchiseId : String,  completion : @escaping (Array<FundraiserModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Fundraisers").whereField("franchiseId", isEqualTo: franchiseId).order(by: "name").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let fundraiserModels = snapshot.documents.compactMap{ try? $0.data(as:FundraiserModel.self) }
                    completion(fundraiserModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func getBusinessByCategory(catId : String) -> Array<B2BModel> {
        
        return B2BModel.b2bModels.filter { b2bModel in
            if b2bModel.catId! == catId {
                return true
            }
            return false
        }
        
    }
    func getAllSalesTransactionByDate(by memberId : String, startDate : Date, endDate : Date, completion : @escaping (Array<FundraiserTransactionModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("FundraiserTransactions").whereField("memberId", isEqualTo: memberId).whereField("date", isGreaterThan: startDate)
            .whereField("date", isLessThan: endDate).addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                }
                else {
                    
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        
                        let salesTransactions = snapshot.documents.compactMap{ try? $0.data(as:FundraiserTransactionModel.self) }
                        completion(salesTransactions, nil)
                        
                        return
                    }
                    completion([], nil)
                }
            }
    }
    
    func getAllFundraiserByDate(by franchiseId : String, startDate : Date, endDate : Date, completion : @escaping (Array<FundraiserModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Fundraisers").whereField("franchiseId", isEqualTo: franchiseId).whereField("createDate", isGreaterThan: startDate)
            .whereField("createDate", isLessThan: endDate).getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                }
                else {
                    
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        
                        let b2bModels = snapshot.documents.compactMap{ try? $0.data(as:FundraiserModel.self) }
                        completion(b2bModels, nil)
                        
                        return
                    }
                    completion([], nil)
                }
        }
    }
    
    func getAllBusinessesByDate(by franchiseId : String, startDate : Date, endDate : Date, completion : @escaping (Array<B2BModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Businesses").whereField("franchiseId", isEqualTo: franchiseId).whereField("createDate", isGreaterThan: startDate)
            .whereField("createDate", isLessThan: endDate).getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error.localizedDescription)
                }
                else {
                    
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        
                        let b2bModels = snapshot.documents.compactMap{ try? $0.data(as:B2BModel.self) }
                        completion(b2bModels, nil)
                        
                        return
                    }
                    completion([], nil)
                }
        }
    }
    
    func getBusinesses(by franchiseId : String,  completion : @escaping (Array<B2BModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Businesses").whereField("franchiseId", isEqualTo: franchiseId).order(by: "name").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let b2bModels = snapshot.documents.compactMap{ try? $0.data(as:B2BModel.self) }
                    completion(b2bModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }

    
    func updateAuthUser(uid : String,name : String, email : String, password : String, completion : @escaping (String?, String?)->Void){
        
        lazy var functions = Functions.functions()
        
        functions.httpsCallable("updateUser").call(["uid" : uid, "name" : name, "email" : email,"password": password]) { result, error in
            if let error = error {
                completion(nil,error.localizedDescription)
            }
            else {
                if let result = result, let data = result.data as? [String : String] {
                    if let response = data["response"] {
                        if response == "failed" {
                            completion(nil,data["value"])
                        }
                        else {
                            completion(data["value"],nil)
                        }
                    }
                }
            }
        }
    }
    
    func makeValidURL(urlString : String)->String{
        let urlHasHttpPrefix = urlString.hasPrefix("http://")
        let urlHasHttpsPrefix = urlString.hasPrefix("https://")
        return (urlHasHttpPrefix || urlHasHttpsPrefix) ? urlString : "http://\(urlString)"
    }
    
    func createAuthUser(name : String, email : String, password : String,isAdmin : Bool, completion : @escaping (String?, String?)->Void){
        
        lazy var functions = Functions.functions()
        
        functions.httpsCallable("createUser").call(["name" : name, "email" : email,"password": password, "isAdmin" : isAdmin] as [String : Any]) { result, error in
            if let error = error {
                completion(nil,error.localizedDescription)
            }
            else {
                if let result = result, let data = result.data as? [String : String] {
                    if let response = data["response"] {
                        if response == "failed" {
                            completion(nil,data["value"])
                        }
                        else {
                            completion(data["value"],nil)
                        }
                    }
                }
            }
        }
    }
    
 
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 115, y: self.view.frame.size.height/2, width: 240, height: 36))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Poppins-Medium", size: 14)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func getAllTrainings(type : String,completion : @escaping (Array<TrainingModel>?,String?)->Void){
        FirebaseStoreManager.db.collection("Trainings").order(by: "title").whereField("type", isEqualTo: type).addSnapshotListener { snapshot, error in
          
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    
                    let traingModels = snapshot.documents.compactMap{ try? $0.data(as: TrainingModel.self) }
                    completion(traingModels, nil)
                    
                    return
                }
                completion([], nil)
            }
        }
    }
    
    func convertSecondstoMinAndSec(totalSeconds : Int) -> String{
     
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        return String(format: "%02i : %02i", minutes, seconds)

    }
    func ProgressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.font = UIFont(name: "Poppins-Regular", size: 11)
    }
    
    func ProgressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
  
    func sentVerificationEmail(){
        self.ProgressHUDShow(text: "")
        Auth.auth().currentUser!.sendEmailVerification { error in
            self.ProgressHUDHide()
            if error == nil {
                self.showMessage(title: "Verify Your Email", message: "We have sent verification mail on your email address. Please verify your email address before Sign In.",shouldDismiss: true)
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }
    func getBusinessData(uid : String, showProgress : Bool){
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Businesses").document(uid).getDocument { snapshot, error in
            if error != nil {
                if showProgress {
                    self.ProgressHUDHide()
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    if let business = try? snapshot.data(as: B2BModel.self) {
                         B2BModel.data = business
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.businessTabbarViewController)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                    }
                }
            }
            
        }
    }
    func getFundraiserBy(uid : String, completion : @escaping (FundraiserModel?)->Void){
        FirebaseStoreManager.db.collection("Fundrasiers").document(uid).getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                
              
                if let fundraiserModel = try? snapshot.data(as: FundraiserModel.self) {
                    completion(fundraiserModel)
                    return
                }
              
                
            }
            completion(nil)
        }
    }
    func getBusinessBy(uid : String, completion : @escaping (B2BModel?)->Void){
        FirebaseStoreManager.db.collection("Businesses").document(uid).getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                
              
                if let b2bModel = try? snapshot.data(as: B2BModel.self) {
                    completion(b2bModel)
                    return
                }
              
                
            }
            completion(nil)
        }
    }
    func getSalesData(uid : String, showProgress : Bool){
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Fundraisers").document(uid).getDocument { snapshot, error in
            if error != nil {
                if showProgress {
                    self.ProgressHUDHide()
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    if let business = try? snapshot.data(as: FundraiserModel.self) {
                        FundraiserModel.data = business
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.fundraiserTabbarViewController)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                    }
                }
            }
            
        }
    }

    func getFranchiseData(uid : String, showProgress : Bool){
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Franchises").document(uid).getDocument { snapshot, error in
            if error != nil {
                if showProgress {
                    self.ProgressHUDHide()
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    if let franchise = try? snapshot.data(as: FranchiseModel.self) {
                        FranchiseModel.data = franchise
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.franchiseTabbarViewController)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                    }
                }
            }
            
        }
    }
    func addLike(b2bId : String){
        let likeModel = LikeModel()
        likeModel.b2bId = b2bId
        likeModel.likeDate = Date()
        try? FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("Likes").document(b2bId).setData(from: likeModel)
    }
    
    func removeLike(b2bId : String){
        FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("Likes").document(b2bId).delete()
    }
    func checkLike(b2bId : String, completion : @escaping (Bool)-> Void){
        FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("Likes").document(b2bId).getDocument { snapshot, error in
            if error == nil,let snapshot = snapshot, snapshot.exists {
                completion(true)
                return
                
            }
            completion(false)
            
        }
    }
    
    func getAllLike(completion : @escaping (Array<LikeModel>?)->Void){
        FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid ?? "123").collection("Likes").order(by: "likeDate",descending: true).addSnapshotListener { snapshot, error in
            if error != nil {
                completion(nil)
            }
            else{
                var likeModels = Array<LikeModel>()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let likeModel = try? qdr.data(as: LikeModel.self) {
                            likeModels.append(likeModel)
                        }
                    }
                }
                
                completion(likeModels)
            }
        }
    }
    
    func getUserData(uid : String, showProgress : Bool)  {
   
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, error) in
            
            
            if error != nil {
                if showProgress {
                    self.ProgressHUDHide()
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                        
                   
    
                        if let user = try? snapshot.data(as: UserModel.self) {
                            
                            if user.userType == "franchise" {
                                
                                self.getFranchiseData(uid: user.uid ?? "123", showProgress: showProgress)
                                return
                            }
                            else if user.userType == "b2b" {
                                self.getBusinessData(uid: user.uid ?? "123", showProgress: showProgress)
                                
                                return
                            }
                            else if user.userType == "sales" {
                                self.getSalesData(uid: user.uid ?? "123", showProgress: showProgress)
                                
                                return
                            }
                            UserModel.data = user
                            
                            if let isAdmin = user.isAdmin,isAdmin {
                                self.beRootScreen(mIdentifier: Constants.StroyBoard.adminTabBarViewController)
                                return
                            }
                           
                            
                            if let phoneNumber = user.phoneNumber, !phoneNumber.isEmpty {
                              
                                        
                                        if self.checkMembershipStatus(currentDate: Constants.currentDate, expireDate: user.expireDate ?? Constants.currentDate) {
                                            self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                                        }
                                        else {
                                            self.beRootScreen(mIdentifier: Constants.StroyBoard.createProfileViewController)
                                        }
                                    
                                }
                                else {
                                    self.beRootScreen(mIdentifier: Constants.StroyBoard.createProfileViewController)
                                }
                             

                            }
                            
                         
                        
                }
                else {
                 
                    DispatchQueue.main.async {
                        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
                    }
                    
                }
                
            }
        }
    }
    

    func addYearToDate(years : Int, currentDate : Date) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.year   = years
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: currentDate)
        return nextDate ?? Date()
    }
    
    func membershipDaysLeft(currentDate : Date, expireDate : Date) -> Int {
        
        return Calendar.current.dateComponents([.day], from: currentDate, to: expireDate).day ?? 0
        
        
    }
    
    
    func checkMembershipStatus(currentDate : Date, expireDate : Date) -> Bool{
        if expireDate > currentDate {
            return true
        }
        return false
    }
    
    
    func getAllCategories(completion : @escaping (Array<CategoryModel>) -> Void) {
        FirebaseStoreManager.db.collection("Categories").order(by: "catName").getDocuments { snapshot, error in
            if let snapshot = snapshot, !snapshot.isEmpty {
                
                let catModels = snapshot.documents.compactMap{ try? $0.data(as: CategoryModel.self) }
                completion(catModels)
                
                return
            }
            completion([])
        }
    }
    
    func getUserDataById(uid : String, completion : @escaping (UserModel?,String?)->Void){
        Firestore.firestore().collection("Users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
              
                
                if let snapshot = snapshot, snapshot.exists {
                    
                   
                       
                        if let userModel = try? snapshot.data(as: UserModel.self) {
                            completion(userModel, nil)
                        }
                    
                    else {
                        completion(nil, "Not Found")
                    }
                    
                    
                    
                }
                else {
                    completion(nil, "Not Found")
                }
             
            }
            }
        }




func navigateToAnotherScreen(mIdentifier : String)  {
    
    let destinationVC = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
    destinationVC.modalPresentationStyle = .fullScreen
    present(destinationVC, animated: true) {
        
    }
}

func myPerformSegue(mIdentifier : String)  {
    performSegue(withIdentifier: mIdentifier, sender: nil)
    
}

func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{
    
    
    var storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    if mIdentifier == Constants.StroyBoard.adminTabBarViewController  {
        storyBoard = UIStoryboard(name: "Admin", bundle: Bundle.main)
    }
    else if mIdentifier == Constants.StroyBoard.franchiseTabbarViewController {
        storyBoard = UIStoryboard(name: "Franchise", bundle: Bundle.main)
    }
    else if mIdentifier == Constants.StroyBoard.businessTabbarViewController {
        storyBoard = UIStoryboard(name: "B2B", bundle: Bundle.main)
    }
    else if mIdentifier == Constants.StroyBoard.fundraiserTabbarViewController {
        storyBoard = UIStoryboard(name: "Sales", bundle: Bundle.main)
    }
    switch mIdentifier {
    case Constants.StroyBoard.entryViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? EntryPageViewController)!
                
    case Constants.StroyBoard.tabBarViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? UITabBarController )!
        
    case Constants.StroyBoard.adminTabBarViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? UITabBarController )!
        
    case Constants.StroyBoard.createProfileViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? CreateProfileViewController)!
        
    case Constants.StroyBoard.franchiseTabbarViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? UITabBarController)!

    case Constants.StroyBoard.businessTabbarViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? UITabBarController)!

    case Constants.StroyBoard.fundraiserTabbarViewController :
        return (storyBoard.instantiateViewController(identifier: mIdentifier) as? UITabBarController)!

    default:
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return (storyBoard.instantiateViewController(identifier: Constants.StroyBoard.entryViewController) as? EntryPageViewController)!
    } 
}

    
func beRootScreen(mIdentifier : String) {
    
    guard let window = self.view.window else {
        self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        self.view.window?.makeKeyAndVisible()
        return
    }
    
    window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
    window.makeKeyAndVisible()
    UIView.transition(with: window,
                      duration: 0.3,
                      options: .transitionCrossDissolve,
                      animations: nil,
                      completion: nil)
    
}




func convertDateAndTimeFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyyy, hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormaterWithoutDash(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd MMM yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormater(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd-MMM-yyyy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateFormaterWithSlash(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd/MM/yy"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}

func convertDateForHomePage(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "EEEE, dd MMMM"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}
func convertDateForVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "dd MMM yyyy, hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return df.string(from: date)
    
}




func convertDateIntoTimeForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "hh:mm a"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
    
}




func convertDateIntoDayDigitForRecurringVoucher(_ date: Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "d"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    return "\(df.string(from: date))"
    
}

func convertDateForShowTicket(_ date: Date, endDate :Date) -> String
{
    let df = DateFormatter()
    df.dateFormat = "E,dd"
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.timeZone = TimeZone.current
    let s = "\(df.string(from: date))-\(df.string(from: endDate))"
    df.dateFormat = "MMM yyyy"
    return "\(s) \(df.string(from: date))"
}


    func addAdminGoal(goalModel : GoalModel, completion : @escaping (_ isSuccess : Bool, _ error : String?)->Void){
            
      let id =  FirebaseStoreManager.db.collection("Admins").document(goalModel.franchiseId ?? "123").collection("Goals").document().documentID
        goalModel.id = id
        try? FirebaseStoreManager.db.collection("Admins").document(goalModel.franchiseId ?? "123").collection("Goals").document(id).setData(from: goalModel) { error in
            
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        }
        
    }
    func addVoucher(voucherModel : VoucherModel, completion : @escaping (_ isSuccess : Bool, _ error : String?)->Void){
            
      
        
        try? FirebaseStoreManager.db.collection("Businesses").document(voucherModel.businessUid ?? "123").collection("Vouchers").document(voucherModel.id ?? "123").setData(from: voucherModel) { error in
            
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        }
        
    }
    
    func addFranchiseGoal(goalModel : GoalModel, completion : @escaping (_ isSuccess : Bool, _ error : String?)->Void){
            
      let id =  FirebaseStoreManager.db.collection("Franchises").document(goalModel.franchiseId ?? "123").collection("Goals").document().documentID
        goalModel.id = id
        try? FirebaseStoreManager.db.collection("Franchises").document(goalModel.franchiseId ?? "123").collection("Goals").document(id).setData(from: goalModel) { error in
            
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        }
        
    }
    
    func addFundraiserGoal(fundraiserId : String,goalModel : GoalModel, completion : @escaping (_ isSuccess : Bool, _ error : String?)->Void){
            
      let id =  FirebaseStoreManager.db.collection("Fundraisers").document(fundraiserId).collection("Goals").document().documentID
        goalModel.id = id
        try? FirebaseStoreManager.db.collection("Fundraisers").document(fundraiserId).collection("Goals").document(id).setData(from: goalModel) { error in
            
            if let error = error {
                completion(false, error.localizedDescription)
            }
            else {
                completion(true, nil)
            }
        }
        
    }
    
    func addUserData(userData : UserModel) {
        
        ProgressHUDShow(text: "")
        userData.userType = "user"
        try?  Firestore.firestore().collection("Users").document(userData.uid ?? "123").setData(from: userData,completion: { error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                self.showError(error!.localizedDescription)
            }
            else {
                self.getUserData(uid: userData.uid ?? "123", showProgress: true)
              
            }
           
        })
                                                                                                                                  
           
    }

func showError(_ message : String) {
    let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    
    alert.addAction(okAction)
    
    self.present(alert, animated: true, completion: nil)
    
}

func showMessage(title : String,message : String, shouldDismiss : Bool = false) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let okAction = UIAlertAction(title: "Ok",style: .default) { action in
        if shouldDismiss {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
    
}


    func authWithFirebase(credential : AuthCredential, type : String,displayName : String) {
        
        ProgressHUDShow(text: "")
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                
                self.showError(error!.localizedDescription)
            }
            else {
                let user = authResult!.user
                let ref =  Firestore.firestore().collection("Users").document(user.uid)
                ref.getDocument { (snapshot, error) in
                    if error != nil {
                        self.showError(error!.localizedDescription)
                    }
                    else {
                        if let doc = snapshot {
                            if doc.exists {
                                self.getUserData(uid: user.uid, showProgress: true)
                                
                            }
                            else {
                                
                             
                                var emailId = ""
                                let provider =  user.providerData
                                var name = ""
                                for firUserInfo in provider {
                                    if let email = firUserInfo.email {
                                        emailId = email
                                    }
                                }
                                
                                if type == "apple" {
                                    name = displayName
                                }
                                else {
                                    name = user.displayName!.capitalized
                                }
                   
                                let userData = UserModel()
                                userData.fullName = name
                                userData.email = emailId
                                userData.uid = user.uid
                                userData.registredAt = user.metadata.creationDate ?? Date()
                                userData.regiType = type
                              
                                self.addUserData(userData: userData)
                            }
                        }
                        
                    }
                }
                
            }
            
        }
    }


public func logout(){

    
    do {
        try Auth.auth().signOut()
        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
    catch {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.entryViewController)
    }
}

}






extension UIImageView {
    func makeRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
    }
    
    
    
    
}



extension UIView {
    
    func addBorderView() {
        layer.borderWidth = 0.8
        layer.borderColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1).cgColor
    }
    
    func smoothShadow(){
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 1.8)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    
    func installBlurEffect(isTop : Bool) {
        self.backgroundColor = UIColor.clear
        var blurFrame = self.bounds
        
        if isTop {
            var statusBarHeight : CGFloat = 0.0
            if #available(iOS 13.0, *) {
                let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
                statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                statusBarHeight = UIApplication.shared.statusBarFrame.height
            }
            
            blurFrame.size.height += statusBarHeight
            blurFrame.origin.y -= statusBarHeight
            
        }
        else {
            let window = UIApplication.shared.windows[0]
            let bottomPadding = window.safeAreaInsets.bottom
            blurFrame.size.height += bottomPadding
            //  blurFrame.origin.y += bottomPadding
        }
        let blur = UIBlurEffect(style:.light)
        let visualeffect = UIVisualEffectView(effect: blur)
        visualeffect.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 0.7)
        visualeffect.frame = blurFrame
        self.addSubview(visualeffect)
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    public var safeAreaFrame: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        }
        else  {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.bottom
        }
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}







extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}



