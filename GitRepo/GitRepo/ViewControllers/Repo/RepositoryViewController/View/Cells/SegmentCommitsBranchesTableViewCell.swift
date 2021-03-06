//
//  SeparatorCommitsBranchesTableViewCell.swift
//  GitRepo
//
//  Created by Дарья Витер on 03/12/2019.
//  Copyright © 2019 Viter. All rights reserved.
//

import UIKit

// Unit Tests

protocol SegmentCommitsBranchesTableViewCellDelegate: class {
	func setSegmentControllerValue(_ value: Int)
	func showWebView(at indexPath: IndexPath)
}

 /// Unit Tests - [SegmentCommitsBranchesTableViewCellTests](x-source-tag://SegmentCommitsBranchesTableViewCellTests)
class SegmentCommitsBranchesTableViewCell: UITableViewCell {
	
	public static let separatorCommitsBranchesReuseId = "SeparatorCommitsBranchesReuseId"
	public weak var delegate: SegmentCommitsBranchesTableViewCellDelegate!
	public var repository: Repository? {
		didSet {
			self.setupViews()
		}
	}
	
	private var segmentControl = UISegmentedControl(items: ["Коммиты", "Ветки"])
	private var tableViewForCommitsOrBranches = UITableView()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .default, reuseIdentifier: reuseIdentifier)
		
		self.backgroundColor = .clear
		
		setupViews()
	}
	
	func setupViews() {
		
		segmentControl.tintColor = UIColor(red: 0, green: 0.4784313725, blue: 1, alpha: 1) // #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		segmentControl.selectedSegmentIndex = 0
		for index in 0...1 {
			segmentControl.setWidth(120, forSegmentAt: index)
		}
		segmentControl.sizeToFit()
		segmentControl.selectedSegmentIndex = 0
		segmentControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
		
		
		tableViewForCommitsOrBranches.backgroundColor = UIColor.white
		tableViewForCommitsOrBranches.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableViewForCommitsOrBranches.layer.cornerRadius = 10
		tableViewForCommitsOrBranches.layer.masksToBounds = true

		tableViewForCommitsOrBranches.dataSource = self
		tableViewForCommitsOrBranches.delegate = self
		
		// add to contentView
		contentView.addSubview(segmentControl)
		contentView.addSubview(tableViewForCommitsOrBranches)
		
		// translatesAutoresizingMaskIntoConstraints
		segmentControl.translatesAutoresizingMaskIntoConstraints = false
		tableViewForCommitsOrBranches.translatesAutoresizingMaskIntoConstraints = false
	}
	
	override func updateConstraints() {
		
		// segmentControl
		NSLayoutConstraint.activate([
			segmentControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant:  10),
			segmentControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
			segmentControl.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20),
			segmentControl.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: -10),
			segmentControl.heightAnchor.constraint(equalToConstant: 30)
			])
		
		// tableViewForCommitsOrBranches
		NSLayoutConstraint.activate([
			tableViewForCommitsOrBranches.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
			tableViewForCommitsOrBranches.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			tableViewForCommitsOrBranches.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			tableViewForCommitsOrBranches.heightAnchor.constraint(equalToConstant: 300),
			tableViewForCommitsOrBranches.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			])
		
		super.updateConstraints()
	}
	
	override class var requiresConstraintBasedLayout: Bool {
		return true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
	}
	
	@objc
	func segmentValueChanged() {
		delegate.setSegmentControllerValue(segmentControl.selectedSegmentIndex)
		tableViewForCommitsOrBranches.reloadData()
	}
	
}

extension SegmentCommitsBranchesTableViewCell: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if segmentControl.selectedSegmentIndex == 0 {
			return repository?.commits?.count ?? 0
		} else {
			return repository?.branches?.count ?? 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		switch segmentControl.selectedSegmentIndex {
		case nil, 0:
			let commitMessage = repository?.commits?[indexPath.row].message ?? ""
			let commitDate = repository?.commits?[indexPath.row].getCommitDateString()

			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
			cell.textLabel?.text = commitMessage
			cell.textLabel?.numberOfLines = 0
			cell.accessoryType = .disclosureIndicator
			cell.detailTextLabel?.text = commitDate ?? ""
			cell.selectionStyle = .default
			
		default:
			cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
			let brancheName = repository?.branches?[indexPath.row].name ?? ""
			cell.textLabel?.text = brancheName
			cell.accessoryType = .none
			cell.selectionStyle = .none
		}
		
		return cell
	}
}

extension SegmentCommitsBranchesTableViewCell: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.cellForRow(at: indexPath)?.isSelected = false
		
		if segmentControl.selectedSegmentIndex == 0 {
			delegate.showWebView(at: indexPath)
		}
	}
}
