package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileDTO
import net.ipv64.kivop.services.api.getUserProfile

class UserViewModel: ViewModel() {
  private var user by mutableStateOf<UserProfileDTO?>(null)
    private set
  
  

  fun fetchUser() {
    viewModelScope.launch {
      val response = getUserProfile() // Call the API service to get user profile
      response?.let { user = it } // Set the user profile in ViewModel state
    }
  }
  
  fun getProfile(): UserProfileDTO? {
    return this.user
  }
  
  
  fun updateUser(){
    
  }
  
  init {

  }
}