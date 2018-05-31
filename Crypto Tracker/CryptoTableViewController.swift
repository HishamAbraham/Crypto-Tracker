//
//  CryptoTableViewController.swift
//  Crypto Tracker
//
//  Created by Hisham Abraham on 5/28/18.
//  Copyright © 2018 Hisham Abraham. All rights reserved.
//

import UIKit
import LocalAuthentication

private let headerHight : CGFloat = 100.0
private let netWorthHight : CGFloat = 45.0

class CryptoTableViewController: UITableViewController, CoinDataDelegate {
    


    var amountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinDate.shared.delegate = self
        CoinDate.shared.getPrices()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportTapped))
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil){
            updateSecureButton()
        }

    }
    
    @objc func reportTapped(){
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinDate.shared.html())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.0)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages{
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(shareVC, animated: true, completion: nil)
        
        
    }
    
    func updateSecureButton() {
        if UserDefaults.standard.bool(forKey: "secure"){
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsecure App", style: .plain, target: self, action: #selector(secureTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Secure App", style: .plain, target: self, action: #selector(secureTapped))
        }
    }
    
    @objc func secureTapped() {
        if UserDefaults.standard.bool(forKey: "secure"){
            UserDefaults.standard.set(false, forKey: "secure")
        } else {
            UserDefaults.standard.set(true, forKey: "secure")
        }
        updateSecureButton()
    }
    override func viewWillAppear(_ animated: Bool) {
         CoinDate.shared.delegate = self
        tableView.reloadData()
        displayNetworth()
    }
    
    func newPrices() {
        displayNetworth()
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CoinDate.shared.coins.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let coin = CoinDate.shared.coins[indexPath.row]
        
        if coin.amount != 0 {
            cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString()) - \(coin.amount)"
        } else {
        cell.textLabel?.text = "\(coin.symbol) - \(coin.priceAsString())"
        }
        cell.imageView?.image = coin.image

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = CoinDate.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHight))
        headerView.backgroundColor = UIColor.white
        
        let netWorthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHight))
        netWorthLabel.text = "My Crypto Net Worth"
        netWorthLabel.textAlignment = .center
        
        headerView.addSubview(netWorthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHight, width: view.frame.size.width, height: headerHight - netWorthHight)
        
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 50)
        
        headerView.addSubview(amountLabel)
        displayNetworth()
        return headerView
        
        
    }
    
    func displayNetworth()  {
        amountLabel.text = CoinDate.shared.netWorthAsString()
    }

}
