import Foundation

protocol LoginView {
    
    func showLoading()
    
    func hideLoading()
    
    func setupUI()
    
    func setupActions()
    
    func emailFieldDidChange()
}
