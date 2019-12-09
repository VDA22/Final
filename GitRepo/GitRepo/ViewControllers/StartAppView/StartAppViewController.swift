//
//  StartAppViewController.swift
//  GitRepo
//
//  Created by Дарья Витер on 30/11/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import UIKit

// Unit Tests

protocol LoaderProtocol {
	func getBaseDataFrom(source: SourceType, endPoint: EndPointType?, baseType: BaseType?, completion: @escaping (_ result: Decodable?, _ error: String?) -> ())
}

protocol RootViewControllerProtocol {
	func switchMainScreen()
	func switchToLogout()
}

class StartAppViewController: UIViewController {
	
	//MARK: UI
	private var greetingLabel = UILabel()
	private var userLoginLabel = UILabel()
	private var welcomeButton = UIButton()
	private var logOutButton = UIButton()
	
	private let loadView = DiamondLoad()
	
	//MARK: service VARs
	
	private var login = UserDefaults.standard.get(with: .oauth_user_login)
	private var logOutCommand: LogOutCommand!
	
	private var loader: LoaderProtocol!
	
	//MARK: Presenter
	var presenter: StartViewPresenterProtocol?
	//MARK: RootView
	var rootView: RootViewControllerProtocol!
	
	//MARK: -
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("login: ", login)
		
		setupViews()
		
		presenter?.setupLoader()
		presenter?.setupLogCoutCommand()
		
		downloadData()
	}
	
	func showButtons(){
		UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
			self.welcomeButton.isEnabled = true
			self.logOutButton.isEnabled = true
			self.loadView.layer.opacity = 0
			self.welcomeButton.layer.opacity = 1
			self.logOutButton.layer.opacity = 1
		}, completion: nil)
	}
	
	/// Loading data from Back or CoreData if it's no connection
	private func downloadData() {
		if UserDefaults.standard.isExist(with: .oauth_user_login) {
			
			
			
			var coreDataService: ManagedObjectFromCoreDataService!
			
			// Load ProjectBase from Back
			loader.getBaseDataFrom(source: .firebase, endPoint: FirebaseApi.getProjects, baseType: nil) {
				result, error in
				
				if error != nil {
					print(error!)
				}
				
				if result == nil {
					// Load ProjectBase From CoreData
					self.loader.getBaseDataFrom(source: .coreData, endPoint: nil, baseType: .projectBase) {
						result,error  in
						
						guard let projectBase = result as? ProjectsBase else {return}
						print(projectBase)
						
						DispatchQueue.main.async {
							
							AppDelegate.shared.projectBase = projectBase
						}
					}
				} else {
					// Save loaded ProjectBase in CoreData
					coreDataService = ManagedObjectFromCoreDataService(withDeleting: true, writeContext: CoreDataStack.shared.writeContext, readContext: CoreDataStack.shared.readContext)
					coreDataService.saveCoreDataObjectsFrom(base: result as? ProjectsBase, baseType: .projectBase)
					
					guard let base = result as? ProjectsBase else {return}
					print(base)
					
					DispatchQueue.main.async {
						AppDelegate.shared.projectBase = base
					}
				}
				
				// Load RepositoryBase From Back
				self.loader.getBaseDataFrom(source: .gitHub, endPoint: GitHubApi.repos, baseType: nil) {
					result, error in
					
					if error != nil {
						print(error!)
					}
					
					if result == nil {
						// Load RepositoryBase From CoreData
						self.loader.getBaseDataFrom(source: .coreData, endPoint: nil, baseType: .repositoryBase) {
							result,error  in
							print(result)
							
							guard let repositoryBase = result as? RepositoriesBase else {return}
							
							DispatchQueue.main.async {
								print(repositoryBase)
								AppDelegate.shared.repositoryBase = repositoryBase
								self.showButtons()
							}
						}
						
					} else {
						// Save loaded RepositoryBase in CoreData
						coreDataService.saveCoreDataObjectsFrom(base: result as? RepositoriesBase, baseType: .repositoryBase)
						DispatchQueue.main.async {
							AppDelegate.shared.repositoryBase = result as? RepositoriesBase
							self.showButtons()
						}
					}	
				}
			}
		}
	}
	
	func setupViews() {
		
		view.backgroundColor = .white
		navigationController?.setNavigationBarHidden(true, animated: true)
		
		view.addSubview(greetingLabel)
		view.addSubview(userLoginLabel)
		view.addSubview(welcomeButton)
		view.addSubview(logOutButton)
		
		if UserDefaults.standard.isExist(with: .oauth_user_login) {
		
			loadView.dotsColor = UIColor(red: 227 / 255, green: 172 / 255, blue: 1, alpha: 1)
			loadView.frame.size = CGSize(width: 70, height: 70)
			loadView.center = CGPoint(x: view.center.x, y: view.center.y + 150)
			loadView.startAnimating()
			view.addSubview(loadView)
			
			welcomeButton.layer.opacity = 0
			logOutButton.layer.opacity = 0
			welcomeButton.isEnabled = true
			logOutButton.isEnabled = true
		}
		
		
		let defWidth = UIScreen.main.bounds.size.width
		
		greetingLabel.translatesAutoresizingMaskIntoConstraints = false
		userLoginLabel.translatesAutoresizingMaskIntoConstraints = false
		welcomeButton.translatesAutoresizingMaskIntoConstraints = false
		logOutButton.translatesAutoresizingMaskIntoConstraints = false
		
		// greetingLabel
		let greetingLabelTitle = (login.isEmpty) ? "Привет" : "Привет,"
		greetingLabel.text = greetingLabelTitle
		greetingLabel.font = UIFont.systemFont(ofSize: 20)
		greetingLabel.textAlignment = .center
		
		NSLayoutConstraint.activate([
			greetingLabel.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 50),
			greetingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			greetingLabel.heightAnchor.constraint(equalToConstant: 70),
			greetingLabel.widthAnchor.constraint(equalToConstant: defWidth),
			greetingLabel.bottomAnchor.constraint(equalTo: userLoginLabel.topAnchor, constant: 25)
			])
		
		// userLoginLabel
		let userLoginLabelTitle = (login.isEmpty) ? "" : login
		userLoginLabel.text = userLoginLabelTitle
		userLoginLabel.font = UIFont.systemFont(ofSize: 24)
		userLoginLabel.textAlignment = .center
		
		NSLayoutConstraint.activate([
			userLoginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			userLoginLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
			userLoginLabel.heightAnchor.constraint(equalToConstant: 100),
			userLoginLabel.widthAnchor.constraint(equalToConstant: defWidth)
			])
		
		// welcomeButton
		let welcomeButtonTitle = (login.isEmpty) ? "Войти" : "Продолжить"
		welcomeButton.setTitle(welcomeButtonTitle, for: .normal)
		welcomeButton.setTitleColor(UIColor(red: 1, green: 0.6, blue: 0, alpha: 0.6), for: .normal)
		welcomeButton.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 0.2)
		welcomeButton.layer.cornerRadius = 20
		welcomeButton.layer.masksToBounds = true
		welcomeButton.addTarget(self, action: #selector(tapWelcomeButton(_:)), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			welcomeButton.topAnchor.constraint(equalTo: userLoginLabel.bottomAnchor, constant: 0),
			welcomeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			welcomeButton.widthAnchor.constraint(equalToConstant: defWidth / 3),
			welcomeButton.heightAnchor.constraint(equalToConstant: 50)
			])
		
		// logOutButton
		logOutButton.isHidden = login.isEmpty
		logOutButton.setTitle("Выйти", for: .normal)
		logOutButton.setTitleColor(UIColor(red: 1, green: 0.6, blue: 0, alpha: 0.8), for: .normal)
		logOutButton.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 0.4)
		logOutButton.layer.cornerRadius = 20
		logOutButton.layer.masksToBounds = true
		logOutButton.addTarget(self, action: #selector(tapLogOutButton), for: .touchUpInside)
		
		NSLayoutConstraint.activate([
			logOutButton.topAnchor.constraint(equalTo: welcomeButton.bottomAnchor, constant: 20),
			logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			logOutButton.widthAnchor.constraint(equalToConstant: defWidth / 3),
			logOutButton.heightAnchor.constraint(equalToConstant: 50),
			logOutButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -50)
			])
		
	}
}

extension StartAppViewController {
	@objc
	func tapWelcomeButton(_ sender: UIButton) {
		
			UIView.animate(withDuration: 0.5, delay: 0.3, options: [], animations: {
				self.greetingLabel.layer.opacity = 1
				self.userLoginLabel.layer.opacity = 1
				self.welcomeButton.layer.opacity = 0
				self.view.layer.opacity = 1
			}, completion: {
				_ in
				
				if sender.titleLabel?.text == "Войти" {
					let registrationView = RequestViewController()
					registrationView.modalPresentationStyle = .fullScreen
					
					self.present(registrationView, animated: false, completion: nil)
				} else {
//					self.switchRootViewControllerToMainScreen()
					guard NSClassFromString("XCTestCase") == nil else { return }
//					guard AppDelegate.shared != nil else { return }
					AppDelegate.shared.rootViewController.switchMainScreen()
				}
			})
	}
	
	/// Logout User
	@objc
	func tapLogOutButton() {
//		let logOtcommand = LogOutCommand()
//		logOtcommand.logOut()
		logOutCommand.logOut()
//		login = UserDefaults.standard.get(with: .oauth_user_login)
		loadView()
		setupViews()
		
	}
}

//MARK: - StartViewProtocol
extension StartAppViewController: StartViewProtocol {
	
	func setLoader(loader: LoaderProtocol?) {
		self.loader = loader
	}
	
	func setLogoutCommand(command: LogOutCommand?) {
		self.logOutCommand = command
	}
}

//MARK: - ManagedViewControllerByRootViewControllerProtocol
extension StartAppViewController: ManagedViewControllerByRootViewControllerProtocol {
	
	func setupRootViewController(_ rootView: RootViewControllerProtocol) {
		self.rootView = rootView
	}
	
	func switchRootViewControllerToMainScreen() {
		rootView.switchMainScreen()
	}
	
	func switchRootViewControllerToLogoutScreen() {
		rootView.switchToLogout()
	}
}